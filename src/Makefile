CXX=clang++
CXXFLAGS=-Oz -march=native -Wall -Wextra -pedantic
SRCBIN=../
BIN=${SRCBIN}moulinette

clean=scan.cc scan.hh

.PHONY:${BIN}

all: ${BIN}

${BIN}: main.cc scan.cc
	${CXX} ${CXXFLAGS} main.cc driver.cc scan.cc -o ${BIN}

scan.cc: scan.ll
	flex scan.ll

clean:
	rm -frv ${clean}

distclean: clean
	rm -rvf ${BIN}
