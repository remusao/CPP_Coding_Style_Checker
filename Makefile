
all:
	@make -C src/	|	grep -v make

clean:
	@make -C src/ clean	| 	grep -v make

distclean: clean
	rm -fv moulinette
