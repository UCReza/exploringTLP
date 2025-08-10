// ~/work/gem5_part2/daxpy_pthreads.c
#define _GNU_SOURCE
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <errno.h>

typedef struct { double *x; double *y; double a; size_t start; size_t end; } daxpy_args_t;

static void *daxpy_worker(void *arg) {
    daxpy_args_t *args = (daxpy_args_t*)arg;
    for (size_t i = args->start; i < args->end; ++i) {
        args->y[i] = args->a * args->x[i] + args->y[i];
    }
    return NULL;
}

static double now_sec() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec * 1e-9;
}

int main(int argc, char **argv) {
    if (argc < 4) { fprintf(stderr, "Usage: %s <size> <threads> <a_scalar>\n", argv[0]); return 1; }
    size_t N = (size_t)strtoull(argv[1], NULL, 10);
    int T = atoi(argv[2]);
    double a = atof(argv[3]);
    if (N == 0 || T <= 0) { fprintf(stderr, "Invalid arguments.\n"); return 1; }

    double *x = (double*)aligned_alloc(64, N * sizeof(double));
    double *y = (double*)aligned_alloc(64, N * sizeof(double));
    if (!x || !y) { perror("alloc"); return 1; }

    for (size_t i = 0; i < N; ++i) {
        x[i] = (double)(i % 100) * 0.5;
        y[i] = (double)((i % 37) - 18) * 0.25;
    }

    pthread_t *threads = (pthread_t*)malloc(sizeof(pthread_t) * T);
    daxpy_args_t *args = (daxpy_args_t*)malloc(sizeof(daxpy_args_t) * T);
    if (!threads || !args) { perror("thread alloc"); return 1; }

    size_t chunk = (N + T - 1) / T;

    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setstacksize(&attr, 256 * 1024); // 256 KB

    double t0 = now_sec();
    for (int t = 0; t < T; ++t) {
        size_t start = (size_t)t * chunk;
        size_t end   = start + chunk;
        if (end > N) end = N;
        args[t].x = x; args[t].y = y; args[t].a = a; args[t].start = start; args[t].end = end;
        int rc = pthread_create(&threads[t], &attr, daxpy_worker, &args[t]);
        if (rc != 0) { fprintf(stderr, "pthread_create failed (%d)\n", rc); return 1; }
    }
    pthread_attr_destroy(&attr);

    for (int t = 0; t < T; ++t) pthread_join(threads[t], NULL);
    double t1 = now_sec();

    double checksum = 0.0;
    for (size_t i = 0; i < N; ++i) checksum += y[i];
    printf("N=%zu threads=%d a=%.6f checksum=%.6f wallclock=%.6f\n",
           N, T, a, checksum, (t1 - t0));

    free(args); free(threads); free(x); free(y);
    return 0;
}
