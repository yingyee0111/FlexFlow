#ifndef _FLEXFLOW_CONST_H_
#define _FLEXFLOW_CONST_H_

enum ActiMode {
  AC_MODE_NONE = 10,
  AC_MODE_RELU = 11,
  AC_MODE_SIGMOID = 12,
  AC_MODE_TANH = 13,
};

enum AggrMode {
  AGGR_MODE_NONE = 20,
  AGGR_MODE_SUM = 21,
  AGGR_MODE_AVG = 22,
};

enum PoolType {
  POOL_MAX = 30,
  POOL_AVG = 31,
};

enum DataType {
  DT_FLOAT = 40,
  DT_DOUBLE = 41,
  DT_INT32 = 42,
  DT_INT64 = 43,
  DT_BOOLEAN = 44,
};

enum LossType {
  LOSS_CATEGORICAL_CROSSENTROPY = 50,
  LOSS_SPARSE_CATEGORICAL_CROSSENTROPY = 51,
  LOSS_MEAN_SQUARED_ERROR_AVG_REDUCE = 52,
  LOSS_MEAN_SQUARED_ERROR_SUM_REDUCE = 53,
};

enum MetricsType {
  METRICS_ACCURACY = 1,
  METRICS_CATEGORICAL_CROSSENTROPY = 2,
  METRICS_SPARSE_CATEGORICAL_CROSSENTROPY = 4,
  METRICS_MEAN_SQUARED_ERROR = 8,
  METRICS_ROOT_MEAN_SQUARED_ERROR = 16,
  METRICS_MEAN_ABSOLUTE_ERROR=32,
};

#endif // _FLEXFLOW_CONST_H_
