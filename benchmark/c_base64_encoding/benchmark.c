
#include <_string.h>
#include <atchops/base64.h>
#include <atlogger/atlogger.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

static clock_t CLOCKS_PER_US = (CLOCKS_PER_SEC / 1000000);

typedef struct {
  // info  captured
  double worst; // worst time
  double best;  // best time
  double sum;   // sum of all success times
  int success;  // number of successes
  int failed;   // number of failures
  // calculated
  int total;     // total runs
  double mean;   // mean of success times
  double median; // TODO median of success times
} statistics;

// Test runners
typedef int(run_test_t)(unsigned char *, int);
int add_half_runner(unsigned char *, int);
int shift_half_runner(unsigned char *, int);
int max_pad_runner(unsigned char *, int);

// Aux functions
int generate_buffers(unsigned char **bufs, int, int);
int do_test(int *, int, statistics *, run_test_t **);

void print_valid_tests() { printf("Valid tests are: 'add_half', 'shift_half', 'max_pad'\n"); }

int main(int argc, char **argv) {
  atlogger_set_logging_level(ATLOGGER_LOGGING_LEVEL_WARN);
  atlogger_set_stream(stderr);

  // int bufspec[] = {100000, 1200,   100000, 1200,   100000, 1200,   100000, 1200,   100000, 1200, 100000,
  //                  1200,   100000, 1200,   100000, 1200,   100000, 1200,   100000, 1200,   0};
  int bufspec[] = {100000, 1650,   100000, 1650,   100000, 1650,   100000, 1650,   100000, 1650, 100000,
                   1650,   100000, 1650,   100000, 1650,   100000, 1650,   100000, 1650,   0};
  int spec_size = 0;
  for (; bufspec[spec_size] != 0; spec_size++)
    ;

  // Determine runner to use
  if (argc < 2) {
    printf("Missing argument <test>:\n");
    printf("Usage: %s <test>\n", argv[0]);
    print_valid_tests();
    return 1;
  }
  unsigned int seed;
  if (argc > 2) {
    seed = atoi(argv[2]);
    printf("Using parsed seed: '%u'\n", seed);
  } else {
    seed = (unsigned int)time(NULL);
    printf("Generated new seed: '%u'\n", seed);
  }
  srand(seed);

  run_test_t *test_runner = NULL;
  char *test = argv[1];
  if (strcmp(test, "add_half") == 0) {
    test_runner = add_half_runner;
  } else if (strcmp(test, "shift_half") == 0) {
    test_runner = shift_half_runner;
  } else if (strcmp(test, "max_pad") == 0) {
    test_runner = max_pad_runner;
  } else {
    printf("%s is not a valid test\n", argv[1]);
    print_valid_tests();
    return 1;
  }

  printf("Running test: %s\n", test);
  for (int i = 0; i < spec_size; i += 2) {
    statistics *stats;

    stats = malloc(sizeof(statistics));
    if (stats == NULL)
      return 1;

    memset(stats, 0, sizeof(statistics));
    stats->best = -1;

    int res = do_test(bufspec, i, stats, &test_runner);

    int d = i >> 1;
    if (res != 0) {
      printf("test %d: failed\n", d);
      continue;
    }
    printf("test %d: best: %lf; worst: %lf; avg: %lf; total: %d\n", d, stats->best, stats->worst, stats->mean,
           stats->success);
    free(stats);
  }

  return 0;
}

int add_half_runner(unsigned char *buf, int buf_size) {
  size_t size = buf_size * 3 / 2;

  unsigned char *encoded = malloc(size * sizeof(unsigned char));
  if (encoded == NULL)
    return 1;

  int res = atchops_base64_encode(buf, buf_size, encoded, size, NULL);
  free(buf);
  if (res != 0) {
    printf("atchops_base64_encode failed with code: %d\n", res);
    return res;
  }

  free(encoded);
  return 0;
}

int shift_half_runner(unsigned char *buf, int buf_size) {
  size_t size = buf_size * 3;
  size = size >> 1;

  unsigned char *encoded = malloc(size * sizeof(unsigned char));
  if (encoded == NULL)
    return 1;

  int res = atchops_base64_encode(buf, buf_size, encoded, size, NULL);
  free(buf);
  if (res != 0) {
    printf("atchops_base64_encode failed with code: %d\n", res);
    return res;
  }

  free(encoded);
  return res;
}

int max_pad_runner(unsigned char *buf, int buf_size) {
  size_t size = buf_size * 4 / 3 + 3;

  unsigned char *encoded = malloc(size * sizeof(unsigned char));
  if (encoded == NULL)
    return 1;

  int res = atchops_base64_encode(buf, buf_size, encoded, size, NULL);
  free(buf);
  if (res != 0) {
    printf("atchops_base64_encode failed with code: %d\n", res);
    return res;
  }

  free(encoded);
  return res;
}

int generate_buffers(unsigned char **bufs, int n, int size) {
  atlogger_log("GEN_BUF", ATLOGGER_LOGGING_LEVEL_INFO, "generating %d buffers of size %lu\n", n, size);
  for (int i = 0; i < n; i++) {
    bufs[i] = malloc(size * sizeof(unsigned char));
    if (bufs[i] == NULL) {
      atlogger_log("GEN_BUF", ATLOGGER_LOGGING_LEVEL_ERROR, "Failed to allocate buffer %d\n", i);
      for (i--; i >= 0; i--) {
        free(bufs[i]);
      }
      free(bufs);
      return 1;
    }
    for (int j = 0; j < size; j++) {
      bufs[i][j] = rand();
    }
    atlogger_log("GEN_BUF", ATLOGGER_LOGGING_LEVEL_DEBUG, "generated buffer %d\n", i);
  }
  return 0;
}

int do_test(int *bufspec, int index, statistics *stats, run_test_t **test_runner) {
  int n = bufspec[index];
  int size = bufspec[index + 1];

  unsigned char **bufs;
  bufs = malloc(n * sizeof(unsigned char *));
  if (bufs == NULL) {
    atlogger_log("DO_TEST", ATLOGGER_LOGGING_LEVEL_ERROR, "Failed to allocate %d buffer pointers\n", n);
    return 1;
  }

  atlogger_log("DO_TEST", ATLOGGER_LOGGING_LEVEL_INFO, "index %d : %d buffers of size %lu\n", index, n, size);

  int res = generate_buffers(bufs, n, size);
  if (res != 0)
    return 1;

  clock_t t;

  for (int i = 0; i < n; i++) {
    atlogger_log("CALL_TEST", ATLOGGER_LOGGING_LEVEL_DEBUG, "calling   iter %d\n", i);
    int res;
    t = clock();
    res = (*test_runner)(bufs[i], size);
    t = clock() - t;
    double time = ((double)t) / CLOCKS_PER_US;
    atlogger_log("CALL_TEST", ATLOGGER_LOGGING_LEVEL_DEBUG, "completed iter %d in %lf microseconds with code %d\n", i,
                 time, res);

    if (time > stats->worst) {
      stats->worst = time;
    }
    if (stats->best < 0 || time < stats->best) {
      stats->best = time;
    }
    stats->sum += time;

    if (res == 0) {
      stats->success++;
    } else {
      stats->failed++;
    }
  }

  stats->mean = stats->sum / stats->success;
  stats->total = stats->success + stats->failed;

  free(bufs);
  return 0;
}
