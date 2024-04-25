// THIS FILE WAS AUTO-GENERATED BY proj. DO NOT MODIFY IT!
// If you would like to modify this datatype, instead modify
// lib/op-attrs/include/op-attrs/parallel_tensor_shape.struct.toml
/* proj-data
{
  "generated_from": "bc7e838003fe037b95d45cd5ab4aa16f"
}
*/

#include "op-attrs/parallel_tensor_shape.dtg.h"

#include "op-attrs/datatype.h"
#include "op-attrs/parallel_tensor_dims.h"
#include <sstream>

namespace FlexFlow {
ParallelTensorShape::ParallelTensorShape(
    ::FlexFlow::ParallelTensorDims const &dims,
    ::FlexFlow::DataType const &data_type)
    : dims(dims), data_type(data_type) {}
bool ParallelTensorShape::operator==(ParallelTensorShape const &other) const {
  return std::tie(this->dims, this->data_type) ==
         std::tie(other.dims, other.data_type);
}
bool ParallelTensorShape::operator!=(ParallelTensorShape const &other) const {
  return std::tie(this->dims, this->data_type) !=
         std::tie(other.dims, other.data_type);
}
} // namespace FlexFlow

namespace std {
size_t hash<FlexFlow::ParallelTensorShape>::operator()(
    FlexFlow::ParallelTensorShape const &x) const {
  size_t result = 0;
  result ^= std::hash<::FlexFlow::ParallelTensorDims>{}(x.dims) + 0x9e3779b9 +
            (result << 6) + (result >> 2);
  result ^= std::hash<::FlexFlow::DataType>{}(x.data_type) + 0x9e3779b9 +
            (result << 6) + (result >> 2);
  return result;
}
} // namespace std

namespace nlohmann {
FlexFlow::ParallelTensorShape
    adl_serializer<FlexFlow::ParallelTensorShape>::from_json(json const &j) {
  return {j.at("dims").template get<::FlexFlow::ParallelTensorDims>(),
          j.at("data_type").template get<::FlexFlow::DataType>()};
}
void adl_serializer<FlexFlow::ParallelTensorShape>::to_json(
    json &j, FlexFlow::ParallelTensorShape const &v) {
  j["__type"] = "ParallelTensorShape";
  j["dims"] = v.dims;
  j["data_type"] = v.data_type;
}
} // namespace nlohmann

namespace FlexFlow {
std::string format_as(ParallelTensorShape const &x) {
  std::ostringstream oss;
  oss << "<ParallelTensorShape";
  oss << " dims=" << x.dims;
  oss << " data_type=" << x.data_type;
  oss << ">";
  return oss.str();
}
std::ostream &operator<<(std::ostream &s, ParallelTensorShape const &x) {
  return s << fmt::to_string(x);
}
} // namespace FlexFlow
