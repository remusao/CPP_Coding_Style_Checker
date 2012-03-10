CXX=clang++
CXXFLAGS=-Oz -march=native -Wall -Wextra -pedantic
SRCBIN=../
BIN=${SRCBIN}moulinette

clean=gmon.out parser parser.cc parser.hh parser.output scan.cc scan.hh stack.hh

.PHONY:${BIN}

all: ${BIN}

${BIN}: main.cc parser.cc scan.cc
	${CXX} ${CXXFLAGS} main.cc driver.cc parser.cc scan.cc -o ${BIN}

parser.cc: parse.yy
	bison parse.yy -o parser.cc

scan.cc: scan.ll
	flex scan.ll

clean:
	rm -frv ${clean}

distclean: clean
	rm -rvf ${BIN}
