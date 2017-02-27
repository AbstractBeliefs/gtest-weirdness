all: test
clean: testclean libraryclean toolclean

CXX = clang++
CC = clang

# Libraries

LIB_CFLAGS = -I include

src/common.o: include/common.h src/common.c
	$(CC) $(LIB_CFLAGS) -c src/common.c -o src/common.o

libraryclean:
	rm -f *.a src/*.o

# Tests

TEST_CXXFLAGS = -I $(GTEST_DIR)/include -I include
TEST_OBJECTS = tests/commontest.o
TEST_LIBRARIES = tests/gtest_main.a

test: tests/test.out
	tests/test.out

tests/commontest.o: tests/testsrc/commontest.cpp src/common.o include/common.h
	$(CXX) $(TEST_CXXFLAGS) -c $< -o $@

tests/test.out: $(TEST_OBJECTS) $(TEST_LIBRARIES)
	$(CXX) $(TEST_CXXFLAGS) -lpthread $^ src/common.o -o $@

testclean:
	rm -f tests/*.a tests/*.o tests/*.out

# Google Test Lib

GTEST_DIR = tests/googletest/googletest
GTEST_CPPFLAGS += -isystem $(GTEST_DIR)/include
GTEST_CXXFLAGS += -g -Wall -Wextra -pthread
GTEST_HEADERS = $(GTEST_DIR)/include/gtest/*.h \
                $(GTEST_DIR)/include/gtest/internal/*.h
GTEST_SRCS_ = $(GTEST_DIR)/src/*.cc $(GTEST_DIR)/src/*.h $(GTEST_HEADERS)

tests/gtest_main.a: tests/gtest-all.o tests/gtest_main.o
	$(AR) $(ARFLAGS) $@ $^

tests/gtest-all.o : $(GTEST_SRCS_)
	$(CXX) $(GTEST_CPPFLAGS) -I$(GTEST_DIR) $(GTEST_CXXFLAGS) -c \
            $(GTEST_DIR)/src/gtest-all.cc -o $@

tests/gtest_main.o : $(GTEST_SRCS_)
	$(CXX) $(GTEST_CPPFLAGS) -I$(GTEST_DIR) $(GTEST_CXXFLAGS) -c \
            $(GTEST_DIR)/src/gtest_main.cc -o $@

.PHONY: all clean test testclean libraryclean toolclean
