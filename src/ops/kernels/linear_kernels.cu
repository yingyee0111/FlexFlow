/* Copyright 2023 CMU, Facebook, LANL, MIT, NVIDIA, and Stanford (alphabetical)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "flexflow/ops/kernels/linear_kernels.h"
#include "flexflow/utils/cuda_helper.h"

namespace FlexFlow {

LinearMeta::LinearMeta(FFHandler handler, int batch_size) : OpMeta(handler) {
  // Allocate an all-one's vector
  float *dram_one_ptr = (float *)malloc(sizeof(float) * batch_size);
  for (int i = 0; i < batch_size; i++) {
    dram_one_ptr[i] = 1.0f;
  }
  float *fb_one_ptr;
  checkCUDA(cudaMalloc(&fb_one_ptr, sizeof(float) * batch_size));
  checkCUDA(cudaMemcpy(fb_one_ptr,
                       dram_one_ptr,
                       sizeof(float) * batch_size,
                       cudaMemcpyHostToDevice));
  one_ptr = (float const *)fb_one_ptr;
  // Allocate descriptors
  checkCUDNN(cudnnCreateActivationDescriptor(&actiDesc));
  checkCUDNN(cudnnCreateTensorDescriptor(&outputTensor));
}

namespace Kernels {
namespace Linear {

bool use_activation(ActiMode mode) {
  switch (mode) {
    case AC_MODE_RELU:
    case AC_MODE_SIGMOID:
    case AC_MODE_TANH:
      return true;
    case AC_MODE_NONE:
      return false;
    default:
      assert(0);
      break;
  }
  return false;
}

void init_kernel(LinearMeta *m, int batch_size, int channel) {
  if (use_activation(m->activation)) {
    cudnnActivationMode_t mode;
    switch (m->activation) {
      case AC_MODE_RELU:
        mode = CUDNN_ACTIVATION_RELU;
        break;
      case AC_MODE_SIGMOID:
        mode = CUDNN_ACTIVATION_SIGMOID;
        break;
      default:
        // Unsupported activation mode
        assert(false);
    }
    checkCUDNN(cudnnSetActivationDescriptor(
        m->actiDesc, mode, CUDNN_PROPAGATE_NAN, 0.0));
    checkCUDNN(cudnnSetTensor4dDescriptor(m->outputTensor,
                                          CUDNN_TENSOR_NCHW,
                                          ff_to_cudnn_datatype(m->output_type),
                                          batch_size,
                                          channel,
                                          1,
                                          1));
  }
}

void forward_kernel_wrapper(LinearMeta const *m,
                            void const *input_ptr,
                            void *output_ptr,
                            void const *weight_ptr,
                            void const *bias_ptr,
                            int in_dim,
                            int out_dim,
                            int batch_size) {
  cudaStream_t stream;
  checkCUDA(get_legion_stream(&stream));

  cudaEvent_t t_start, t_end;
  if (m->profiling) {
    cudaEventCreate(&t_start);
    cudaEventCreate(&t_end);
    cudaEventRecord(t_start, stream);
  }
  Internal::forward_kernel(m,
                           input_ptr,
                           output_ptr,
                           weight_ptr,
                           bias_ptr,
                           in_dim,
                           out_dim,
                           batch_size,
                           stream);

  if (m->profiling) {
    cudaEventRecord(t_end, stream);
    checkCUDA(cudaEventSynchronize(t_end));
    float elapsed = 0;
    checkCUDA(cudaEventElapsedTime(&elapsed, t_start, t_end));
    cudaEventDestroy(t_start);
    cudaEventDestroy(t_end);
    printf("%s [Linear] forward time = %.2lfms\n", m->op_name, elapsed);
    // print_tensor<float>((float*)input_ptr, in_dim * batch_size,
    // "[Linear:forward:input]"); print_tensor<float>((float*)weight_ptr, in_dim
    // * out_dim, "[Linear:forward:kernel]");
    // print_tensor<float>((float*)output_ptr, out_dim * batch_size,
    // "[Linear:forward:output]");
  }
}

void backward_kernel_wrapper(LinearMeta const *m,
                             void const *input_ptr,
                             void *input_grad_ptr,
                             void const *output_ptr,
                             void *output_grad_ptr,
                             void const *kernel_ptr,
                             void *kernel_grad_ptr,
                             void *bias_grad_ptr,
                             int in_dim,
                             int out_dim,
                             int batch_size) {
  cudaStream_t stream;
  checkCUDA(get_legion_stream(&stream));

  cudaEvent_t t_start, t_end;
  if (m->profiling) {
    cudaEventCreate(&t_start);
    cudaEventCreate(&t_end);
    cudaEventRecord(t_start, stream);
  }
  Internal::backward_kernel(m,
                            input_ptr,
                            input_grad_ptr,
                            output_ptr,
                            output_grad_ptr,
                            kernel_ptr,
                            kernel_grad_ptr,
                            bias_grad_ptr,
                            in_dim,
                            out_dim,
                            batch_size,
                            stream);
  if (m->profiling) {
    cudaEventRecord(t_end, stream);
    checkCUDA(cudaEventSynchronize(t_end));
    float elapsed = 0;
    checkCUDA(cudaEventElapsedTime(&elapsed, t_start, t_end));
    cudaEventDestroy(t_start);
    cudaEventDestroy(t_end);
    printf("%s Linear backward time = %.2lfms\n", m->op_name, elapsed);
    // print_tensor<float>(acc_output_grad.ptr, acc_output_grad.rect.volume(),
    // "[Linear:backward:output_grad]");
    // print_tensor<float>(acc_kernel_grad.ptr, acc_kernel_grad.rect.volume(),
    // "[Linear:backward:kernel_grad]"); print_tensor<1,
    // float>(acc_bias_grad.ptr, acc_bias_grad.rect,
    // "[Linear:backward:bias_grad]"); print_tensor<float>(input_grad,
    // acc_input.rect.volume(), "[Linear:backward:input_grad]");
  }
}

/*
__host__
Parameter* Linear::get_parameter(int index)
{
  if (index == 0) {
    return &weights[0];
  } else if (index == 1){
    return &weights[1];
  } else {
    assert(0);
    return NULL;
  }
}
*/
namespace Internal {

void forward_kernel(LinearMeta const *m,
                    void const *input_ptr,
                    void *output_ptr,
                    void const *weight_ptr,
                    void const *bias_ptr,
                    int in_dim,
                    int out_dim,
                    int batch_size,
                    ffStream_t stream) {
  checkCUDA(cublasSetStream(m->handle.blas, stream));
  checkCUDNN(cudnnSetStream(m->handle.dnn, stream));
  float alpha = 1.0f, beta = 0.0f;
  cudaDataType_t input_type = ff_to_cuda_datatype(m->input_type);
  cudaDataType_t weight_type = ff_to_cuda_datatype(m->weight_type);
  cudaDataType_t output_type = ff_to_cuda_datatype(m->output_type);
#if CUDA_VERSION >= 11000
  // TODO: currently set the default to CUBLAS_COMPUTE_16F for best performance
  cublasComputeType_t compute_type = CUBLAS_COMPUTE_16F;
#else
  cudaDataType_t compute_type = CUDA_R_32F;
#endif
  checkCUDA(cublasGemmEx(m->handle.blas,
                         CUBLAS_OP_T,
                         CUBLAS_OP_N,
                         out_dim,
                         batch_size,
                         in_dim,
                         &alpha,
                         weight_ptr,
                         weight_type,
                         in_dim,
                         input_ptr,
                         input_type,
                         in_dim,
                         &beta,
                         output_ptr,
                         output_type,
                         out_dim,
                         compute_type,
                         CUBLAS_GEMM_DEFAULT_TENSOR_OP));
  // use_bias = True
  if (bias_ptr != NULL) {
    checkCUDA(cublasGemmEx(m->handle.blas,
                           CUBLAS_OP_T,
                           CUBLAS_OP_N,
                           out_dim,
                           batch_size,
                           1,
                           &alpha,
                           bias_ptr,
                           weight_type,
                           1,
                           m->one_ptr,
                           CUDA_R_32F,
                           1,
                           &alpha,
                           output_ptr,
                           output_type,
                           out_dim,
                           compute_type,
                           CUBLAS_GEMM_DEFAULT_TENSOR_OP));
  }
  if (use_activation(m->activation)) {
    checkCUDNN(cudnnActivationForward(m->handle.dnn,
                                      m->actiDesc,
                                      &alpha,
                                      m->outputTensor,
                                      output_ptr,
                                      &beta,
                                      m->outputTensor,
                                      output_ptr));
  } else if (m->activation == AC_MODE_GELU) {
    size_t elements = (size_t)out_dim * (size_t)batch_size;
    constexpr float B = 0.7978845608028654f;   // sqrt(2.0/M_PI)
    constexpr float C = 0.035677408136300125f; // 0.044715 * sqrt(2.0/M_PI)
    gelu_forward_kernel<<<GET_BLOCKS(elements), CUDA_NUM_THREADS>>>(
        elements, B, C, (float *)output_ptr);
  } else if (m->activation == AC_MODE_NONE) {
    // Do nothing
  } else {
    assert(false && "Unsupported activation for Linear");
  }
}

void backward_kernel(LinearMeta const *m,
                     void const *input_ptr,
                     void *input_grad_ptr,
                     void const *output_ptr,
                     void *output_grad_ptr,
                     void const *kernel_ptr,
                     void *kernel_grad_ptr,
                     void *bias_grad_ptr,
                     int in_dim,
                     int out_dim,
                     int batch_size,
                     ffStream_t stream) {
  checkCUDA(cublasSetStream(m->handle.blas, stream));
  checkCUDNN(cudnnSetStream(m->handle.dnn, stream));

  float alpha = 1.0f;
  cudaDataType_t input_type = ff_to_cuda_datatype(m->input_type);
  cudaDataType_t weight_type = ff_to_cuda_datatype(m->weight_type);
  cudaDataType_t output_type = ff_to_cuda_datatype(m->output_type);
#if CUDA_VERSION >= 11000
  // TODO: currently set the default to CUBLAS_COMPUTE_16F for best performance
  cublasComputeType_t compute_type = CUBLAS_COMPUTE_16F;
#else
  cudaDataType_t compute_type = CUDA_R_32F;
#endif
  int output_size = out_dim * batch_size;
  if (m->activation == AC_MODE_RELU) {
    relu_backward_kernel(
        m->output_type, output_grad_ptr, output_ptr, output_size, stream);
  } else if (m->activation == AC_MODE_SIGMOID) {
    sigmoid_backward_kernel(
        m->output_type, output_grad_ptr, output_ptr, output_size, stream);
  } else {
    // TODO: only support relu and sigmoid for now
    assert(m->activation == AC_MODE_NONE);
  }
  // Compute weight gradiant
  // NOTE: we use alpha=1 for kernel_grad to accumulate gradients
  checkCUDA(cublasGemmEx(m->handle.blas,
                         CUBLAS_OP_N,
                         CUBLAS_OP_T,
                         in_dim,
                         out_dim,
                         batch_size,
                         &alpha,
                         input_ptr,
                         input_type,
                         in_dim,
                         output_grad_ptr,
                         output_type,
                         out_dim,
                         &alpha,
                         kernel_grad_ptr,
                         weight_type,
                         in_dim,
                         compute_type,
                         CUBLAS_GEMM_DEFAULT_TENSOR_OP));
  // Compute bias gradiant
  // NOTE: we use alpha=1 for bias_grad to accumulate gradients
  // use_bias = True
  if (bias_grad_ptr != NULL) {
    checkCUDA(cublasGemmEx(m->handle.blas,
                           CUBLAS_OP_N,
                           CUBLAS_OP_T,
                           1,
                           out_dim,
                           batch_size,
                           &alpha,
                           m->one_ptr,
                           CUDA_R_32F,
                           1,
                           output_grad_ptr,
                           output_type,
                           out_dim,
                           &alpha,
                           bias_grad_ptr,
                           weight_type,
                           1,
                           compute_type,
                           CUBLAS_GEMM_DEFAULT_TENSOR_OP));
  }
  // Compute data gradiant
  // NOTE: we use alpha=1 for input_grad to accumulate gradients
  if (input_grad_ptr != NULL) {
    checkCUDA(cublasGemmEx(m->handle.blas,
                           CUBLAS_OP_N,
                           CUBLAS_OP_N,
                           in_dim,
                           batch_size,
                           out_dim,
                           &alpha,
                           kernel_ptr,
                           weight_type,
                           in_dim,
                           output_grad_ptr,
                           output_type,
                           out_dim,
                           &alpha,
                           input_grad_ptr,
                           input_type,
                           in_dim,
                           compute_type,
                           CUBLAS_GEMM_DEFAULT_TENSOR_OP));
  }
}

} // namespace Internal
} // namespace Linear
} // namespace Kernels
} // namespace FlexFlow
