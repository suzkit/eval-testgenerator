CXXFLAGS = -I ../../include -L/home/klee/klee_build/lib/ -DKLEE -g -fprofile-arcs -ftest-coverage -DNDEBUG
LDFLAGS = -lkleeRuntest -lgcov

#--------------------------------------#

src = binarysearch.cpp
bc = binarysearch.bc
bin = binarysearch
lcovfile = binarysearch.lcov

#--------------------------------------#

.PHONY: clean klee kleeopt kleestat gcov

#--------------------------------------#

$(bin): $(src)
	g++ $(CXXFLAGS) -o $@ $< $(LDFLAGS)

$(bc): $(src)
	clang -I ../../include -emit-llvm -DKLEE -DNDEBUG -c -g -O0 -Xclang -disable-O0-optnone $<

cov: $(bc) $(bin)
	klee $(bc)
	#klee-replay $(bin) klee-last/*ktest
	./klee-replay.sh $(bin)
	gcov -b $(bin)
	TZ=-9 lcov -c -b . -d . -o $(lcovfile)
	genhtml -o html $(lcovfile)
	ktest-tool klee-last/*ktest > klee-last/ktest-tool-result.txt
	klee-stats klee-last > klee-last/klee-stats.txt

gcov:
	gcov -b $(bin)
	TZ=-9 lcov -c -b . -d . -o $(lcovfile)
	genhtml -o html $(lcovfile)

klee:
	klee $(bc)

kleeopt:
	klee --optimize $(bc)
	ktest-tool klee-last/*ktest > klee-last/ktest-tool-result.txt
	klee-stats klee-last > klee-last/klee-stats.txt

kleestat:
	ktest-tool klee-last/*ktest > klee-last/ktest-tool-result.txt
	klee-stats klee-last > klee-last/klee-stats.txt

clean:
	rm -rf $(bin) $(bc) *gcda *gcno *lcov klee-out* html klee-last
