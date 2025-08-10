# ~/work/gem5_part2/Makefile
arm-static:
	@echo "Building static aarch64 Linux binary: daxpy_aarch64"
	@aarch64-linux-gnu-gcc daxpy_pthreads.c -o daxpy_aarch64 \
		-O2 -static -pthread -D_GNU_SOURCE \
		-fno-tree-vectorize -fno-tree-slp-vectorize -fno-unroll-loops \
		-mbranch-protection=none

clean:
	@rm -f daxpy_aarch64
