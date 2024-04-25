// THIS FILE WAS AUTO-GENERATED BY proj. DO NOT MODIFY IT!
// If you would like to modify this datatype, instead modify
// lib/op-attrs/src/op-attrs/ops/conv_2d_parallel_input_shape.struct.toml
/* proj-data
{
  "generated_from": "d80394bdc90f843372760310b6d17a22"
}
*/

#include "op-attrs/ops/conv_2d_parallel_input_shape.dtg.h"

#include "op-attrs/datatype.dtg.h"
#include "op-attrs/shard_parallel_dim.dtg.h"
#include <sstream>

namespace FlexFlow {
Conv2DParallelInputShape::Conv2DParallelInputShape(
    ::FlexFlow::ShardParallelDim const &sample_dim,
    ::FlexFlow::ShardParallelDim const &channel_dim,
    ::FlexFlow::ShardParallelDim const &height_dim,
    ::FlexFlow::ShardParallelDim const &width_dim,
    int const &sum_reduction_degree,
    int const &discard_copy_reduction_degree,
    ::FlexFlow::DataType const &datatype)
    : sample_dim(sample_dim), channel_dim(channel_dim), height_dim(height_dim),
      width_dim(width_dim), sum_reduction_degree(sum_reduction_degree),
      discard_copy_reduction_degree(discard_copy_reduction_degree),
      datatype(datatype) {}
bool Conv2DParallelInputShape::operator==(
    Conv2DParallelInputShape const &other) const {
  return std::tie(this->sample_dim,
                  this->channel_dim,
                  this->height_dim,
                  this->width_dim,
                  this->sum_reduction_degree,
                  this->discard_copy_reduction_degree,
                  this->datatype) ==
         std::tie(other.sample_dim,
                  other.channel_dim,
                  other.height_dim,
                  other.width_dim,
                  other.sum_reduction_degree,
                  other.discard_copy_reduction_degree,
                  other.datatype);
}
bool Conv2DParallelInputShape::operator!=(
    Conv2DParallelInputShape const &other) const {
  return std::tie(this->sample_dim,
                  this->channel_dim,
                  this->height_dim,
                  this->width_dim,
                  this->sum_reduction_degree,
                  this->discard_copy_reduction_degree,
                  this->datatype) !=
         std::tie(other.sample_dim,
                  other.channel_dim,
                  other.height_dim,
                  other.width_dim,
                  other.sum_reduction_degree,
                  other.discard_copy_reduction_degree,
                  other.datatype);
}
bool Conv2DParallelInputShape::operator<(
    Conv2DParallelInputShape const &other) const {
  return std::tie(this->sample_dim,
                  this->channel_dim,
                  this->height_dim,
                  this->width_dim,
                  this->sum_reduction_degree,
                  this->discard_copy_reduction_degree,
                  this->datatype) <
         std::tie(other.sample_dim,
                  other.channel_dim,
                  other.height_dim,
                  other.width_dim,
                  other.sum_reduction_degree,
                  other.discard_copy_reduction_degree,
                  other.datatype);
}
bool Conv2DParallelInputShape::operator>(
    Conv2DParallelInputShape const &other) const {
  return std::tie(this->sample_dim,
                  this->channel_dim,
                  this->height_dim,
                  this->width_dim,
                  this->sum_reduction_degree,
                  this->discard_copy_reduction_degree,
                  this->datatype) >
         std::tie(other.sample_dim,
                  other.channel_dim,
                  other.height_dim,
                  other.width_dim,
                  other.sum_reduction_degree,
                  other.discard_copy_reduction_degree,
                  other.datatype);
}
bool Conv2DParallelInputShape::operator<=(
    Conv2DParallelInputShape const &other) const {
  return std::tie(this->sample_dim,
                  this->channel_dim,
                  this->height_dim,
                  this->width_dim,
                  this->sum_reduction_degree,
                  this->discard_copy_reduction_degree,
                  this->datatype) <=
         std::tie(other.sample_dim,
                  other.channel_dim,
                  other.height_dim,
                  other.width_dim,
                  other.sum_reduction_degree,
                  other.discard_copy_reduction_degree,
                  other.datatype);
}
bool Conv2DParallelInputShape::operator>=(
    Conv2DParallelInputShape const &other) const {
  return std::tie(this->sample_dim,
                  this->channel_dim,
                  this->height_dim,
                  this->width_dim,
                  this->sum_reduction_degree,
                  this->discard_copy_reduction_degree,
                  this->datatype) >=
         std::tie(other.sample_dim,
                  other.channel_dim,
                  other.height_dim,
                  other.width_dim,
                  other.sum_reduction_degree,
                  other.discard_copy_reduction_degree,
                  other.datatype);
}
} // namespace FlexFlow

namespace std {
size_t hash<FlexFlow::Conv2DParallelInputShape>::operator()(
    FlexFlow::Conv2DParallelInputShape const &x) const {
  size_t result = 0;
  result ^= std::hash<::FlexFlow::ShardParallelDim>{}(x.sample_dim) +
            0x9e3779b9 + (result << 6) + (result >> 2);
  result ^= std::hash<::FlexFlow::ShardParallelDim>{}(x.channel_dim) +
            0x9e3779b9 + (result << 6) + (result >> 2);
  result ^= std::hash<::FlexFlow::ShardParallelDim>{}(x.height_dim) +
            0x9e3779b9 + (result << 6) + (result >> 2);
  result ^= std::hash<::FlexFlow::ShardParallelDim>{}(x.width_dim) +
            0x9e3779b9 + (result << 6) + (result >> 2);
  result ^= std::hash<int>{}(x.sum_reduction_degree) + 0x9e3779b9 +
            (result << 6) + (result >> 2);
  result ^= std::hash<int>{}(x.discard_copy_reduction_degree) + 0x9e3779b9 +
            (result << 6) + (result >> 2);
  result ^= std::hash<::FlexFlow::DataType>{}(x.datatype) + 0x9e3779b9 +
            (result << 6) + (result >> 2);
  return result;
}
} // namespace std

namespace nlohmann {
FlexFlow::Conv2DParallelInputShape
    adl_serializer<FlexFlow::Conv2DParallelInputShape>::from_json(
        json const &j) {
  return {j.at("sample_dim").template get<::FlexFlow::ShardParallelDim>(),
          j.at("channel_dim").template get<::FlexFlow::ShardParallelDim>(),
          j.at("height_dim").template get<::FlexFlow::ShardParallelDim>(),
          j.at("width_dim").template get<::FlexFlow::ShardParallelDim>(),
          j.at("sum_reduction_degree").template get<int>(),
          j.at("discard_copy_reduction_degree").template get<int>(),
          j.at("datatype").template get<::FlexFlow::DataType>()};
}
void adl_serializer<FlexFlow::Conv2DParallelInputShape>::to_json(
    json &j, FlexFlow::Conv2DParallelInputShape const &v) {
  j["__type"] = "Conv2DParallelInputShape";
  j["sample_dim"] = v.sample_dim;
  j["channel_dim"] = v.channel_dim;
  j["height_dim"] = v.height_dim;
  j["width_dim"] = v.width_dim;
  j["sum_reduction_degree"] = v.sum_reduction_degree;
  j["discard_copy_reduction_degree"] = v.discard_copy_reduction_degree;
  j["datatype"] = v.datatype;
}
} // namespace nlohmann

namespace rc {
Gen<FlexFlow::Conv2DParallelInputShape>
    Arbitrary<FlexFlow::Conv2DParallelInputShape>::arbitrary() {
  return gen::construct<FlexFlow::Conv2DParallelInputShape>(
      gen::arbitrary<::FlexFlow::ShardParallelDim>(),
      gen::arbitrary<::FlexFlow::ShardParallelDim>(),
      gen::arbitrary<::FlexFlow::ShardParallelDim>(),
      gen::arbitrary<::FlexFlow::ShardParallelDim>(),
      gen::arbitrary<int>(),
      gen::arbitrary<int>(),
      gen::arbitrary<::FlexFlow::DataType>());
}
} // namespace rc

namespace FlexFlow {
std::string format_as(Conv2DParallelInputShape const &x) {
  std::ostringstream oss;
  oss << "<Conv2DParallelInputShape";
  oss << " sample_dim=" << x.sample_dim;
  oss << " channel_dim=" << x.channel_dim;
  oss << " height_dim=" << x.height_dim;
  oss << " width_dim=" << x.width_dim;
  oss << " sum_reduction_degree=" << x.sum_reduction_degree;
  oss << " discard_copy_reduction_degree=" << x.discard_copy_reduction_degree;
  oss << " datatype=" << x.datatype;
  oss << ">";
  return oss.str();
}
std::ostream &operator<<(std::ostream &s, Conv2DParallelInputShape const &x) {
  return s << fmt::to_string(x);
}
} // namespace FlexFlow
