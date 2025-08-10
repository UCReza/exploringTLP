WORK="/Users/rezashrestha/Documents/MSCS-531/Week7/work"
cd "$WORK"

# If you used my source with the 256KB stack attr, keep it. Otherwise, update your daxpy_pthreads.c:
#   add before the create loop:
#       pthread_attr_t attr; pthread_attr_init(&attr);
#       pthread_attr_setstacksize(&attr, 131072); // 128 KB
#   pass &attr to pthread_create(..., &attr, ...)
#   pthread_attr_destroy(&attr);

docker run --rm \
  -v "$PWD":/work -w /work \
  ghcr.io/muslcc/aarch64-linux-musl-cross bash -lc '
    set -e
    aarch64-linux-musl-gcc daxpy_pthreads.c -o daxpy_pthreads_arm \
      -O2 -pthread -D_GNU_SOURCE \
      -fno-tree-vectorize -fno-tree-slp-vectorize -fno-unroll-loops \
      -static
    echo "--- file ---"; file daxpy_pthreads_arm
    echo "--- BTI check ---"
    aarch64-linux-musl-objdump -d daxpy_pthreads_arm | grep -qi "\bbti\b" && echo "BTI found ❌" || echo "No BTI found ✅"
'