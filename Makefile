src = binarysearch.cpp
bc = binarysearch.bc
bin = binarysearch
lcovfile = binarysearch.lcov

.PHONY: clean klee kleeopt kleestat

$(bc): $(src)
	clang -I ../../include -emit-llvm -DKLEE -c -g -O0 -Xclang -disable-O0-optnone $<

$(bin): $(src)
	gcc -g -fprofile-arcs -ftest-coverage -o $@ $< -lgcov

cov: $(bc) $(bin)
	klee $(bc)
	klee-replay $(bin) klee-last/*ktest
	gcov -b $<
	TZ=-9 lcov -c -b . -d . -o $(lcovfile)
	genhtml -o html $(lcovfile)

klee:
	klee $(bc)
	ktest-tool klee-last/*ktest > klee-last/ktest-tool-result.txt
	klee-stats klee-last > klee-last/klee-stats.txt

kleeopt:
	klee --optimize $(bc)
	ktest-tool klee-last/*ktest > klee-last/ktest-tool-result.txt
	klee-stats klee-last > klee-last/klee-stats.txt

kleestat:
	ktest-tool klee-last/*ktest > klee-last/ktest-tool-result.txt
	klee-stats klee-last > klee-last/klee-stats.txt

clean:
	rm -rf $(bin) $(bc) *gcda *gcno *lcov klee-out* html klee-last
