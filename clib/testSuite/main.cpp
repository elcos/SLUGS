#include "catch_default_main.hpp" // This brings in a default implementation for main()
#include "circBuffer.h"


TEST_CASE("Peak muestra el proximo elemento a retirar", "Peak debe de mostrar el proximo elemento que readFront nos daria"){

    struct CircBuffer buffer;
    int x;

    CBRef bp = &buffer;
    newCircBuffer(bp);

    writeBack(bp, 5);
    REQUIRE(peak(bp) == 5);

    writeBack(bp, 2);
    REQUIRE(peak(bp) == 5);
    x = readFront(bp);
    REQUIRE_FALSE(peak(bp) == 5);
    REQUIRE(peak(bp) == 2);


    writeBack(bp, 6);
    REQUIRE(peak(bp) == 2);
    x = readFront(bp);
    REQUIRE(peak(bp) == 6);
    x = readFront(bp);
    REQUIRE_FALSE(peak(bp) == 6);
    REQUIRE(peak(bp) == 0);
}

  TEST_CASE( "Anadir y quitar elementos", "La cola debe de anadir y remover elementos de manera adecuada" )
  {
      struct CircBuffer buffer;

  		CBRef bp = &buffer;
  		newCircBuffer(bp);

  		int x,i,z;


  		// Anadir un elemento
	    writeBack(bp, 5);  //escribe  un  byte  al final del  buffer circular  e incrementa  el contador de desbordamiento  si esto  ocurre
        writeBack(bp, 2);
        writeBack(bp, 6);
        writeBack(bp, 9);

        REQUIRE(getLength(bp) == 4);

        x=readHead(bp);
        printf("\ncabeza=%d\n",x);
        z=readFront(bp);
        x=readHead(bp);
        printf("\ncabeza=%d\n",x);
        printf("\nfrente=%d\n",z);

        z=readFront(bp);
        printf("\nfrente=%d\n",z);
  	  REQUIRE( peak(bp) == 4 ); //regresa  el valor de la  cabeza  si  el  buffer  no  esta  vacio.
      REQUIRE( getLength(bp) == 4 );


      // Quitar un elemento
     REQUIRE(readHead(bp) == 0 );
     x = readFront(bp);  //lee  la  cabeza  del  bufer  circular y actualiza  el  valor  de la cabeza siempre  y  cuando  no  haya desbordamiento.
     writeBack(bp, 8);
      REQUIRE( x == 5 );

      REQUIRE( peak(bp) == 8 );

      REQUIRE( getLength(bp) == 1);

      REQUIRE( getOverflow(bp) == 0 );

//      freeCircBuffer(bp)
  }
