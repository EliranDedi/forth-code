: assert-empty
	depth 0 > if
		abort" Stack is not empty"
	then
	;

: ld @ ;
: st ! ;

: ,list ( allocate list )
	here >r , 0 , r>
	;

: list
	create ,list drop
	;

: list@ ( L - data tail )
	dup @ swap 1 th @ swap
	;

: .list ( L )
	dup ?
	1 th ?
	;

: list! ( from to )
	2 cells 0 do
		over i + c@ over i + c!
	loop
	2drop
	;

: ,dup-list ( L )
	here >r dup @ , 1 th @ , here r>
	;
: list-data	( L ) ;
: list-tail	( L ) 1 th ;

: list-step	( L ) list-tail @ ;
: list-last?	( L ) list-tail @ 0= ;

: list-append ( data list ) swap ,list swap list-tail ! ;
: list-prepend ( data list ) ;

: list-append ( data list )
	swap ,list swap
	over list-tail over list-tail @ swap !
	list-tail ! ;

: list-prepend ( data list )
	dup list-data @ over list-append
	st
	;

: list-print ( L )
	dup 0 > if
		dup list-data @ . ." -> " list-step recurse
	else
		drop ." NIL"
	then ;

: printy
	dup 0 > if
		list-data @ . ." -> "
	else
		." NIL" cr
	then ;

\ pass a list address to the xt
\ in C, this would be list_execute(&l, function_pointer);
: list-execute ( xt L )
	dup 0= if
		2drop exit
	then
	2dup 2>r swap execute 2r>
	list-step recurse ;

( if xt returns true, return that list. )
: list-cond-execute ( xt L )
	dup 0= if nip exit then
	over over swap execute
	if
		nip exit
	then
	list-step recurse ;

: list-reduce { xt L }
	L 0= if exit then
	L list-data @ L list-step to L
	begin	( init )
		L list-data xt execute
		L list-step to L
		L 0=
	until
	;

: list-find-last ( L - L )
	['] list-last? swap list-cond-execute
	;

: list-length-helper drop 1+ ;
: list-length ( L - n )
	0 swap
	['] list-length-helper swap
	list-execute ;
