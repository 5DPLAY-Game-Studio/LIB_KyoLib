/*
  Copyright (c) 2008, Adobe Systems Incorporated
  All rights reserved.

  Redistribution and use in source and binary forms, with or without 
  modification, are permitted provided that the following conditions are
  met:

  * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
  
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the 
    documentation and/or other materials provided with the distribution.
  
  * Neither the name of Adobe Systems Incorporated nor the names of its 
    contributors may be used to endorse or promote products derived from 
    this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.adobe.crypto
{
	import com.adobe.utils.IntUtil;
	import flash.utils.ByteArray;
	import mx.utils.Base64Encoder;
	
	/**
	 * The SHA-224 algorithm
	 * 
	 * @see http://csrc.nist.gov/publications/fips/fips180-2/fips180-2withchangenotice.pdf
	 */
	public class SHA224
	{
		public static var digest:ByteArray;
		
		/**
		 *  Performs the SHA224 hash algorithm on a string.
		 *
		 *  @param s		The string to hash
		 *  @return			A string containing the hash value of s
		 *  @langversion	ActionScript 3.0
		 *  @playerversion	9.0
		 *  @tiptext
		 */
		public static function hash( s:String ):String {
			var blocks:Array = createBlocksFromString( s );
			var byteArray:ByteArray = hashBlocks( blocks );
			return IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true );
		}
		
		/**
		 *  Performs the SHA224 hash algorithm on a ByteArray.
		 *
		 *  @param data		The ByteArray data to hash
		 *  @return			A string containing the hash value of data
		 *  @langversion	ActionScript 3.0
		 *  @playerversion	9.0
		 */
		public static function hashBytes( data:ByteArray ):String
		{
			var blocks:Array = createBlocksFromByteArray( data );
			var byteArray:ByteArray = hashBlocks(blocks);
			return IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true )
					+ IntUtil.toHex( byteArray.readInt(), true );
		}
		
		/**
		 *  Performs the SHA224 hash algorithm on a string, then does
		 *  Base64 encoding on the result.
		 *
		 *  @param s		The string to hash
		 *  @return			The base64 encoded hash value of s
		 *  @langversion	ActionScript 3.0
		 *  @playerversion	9.0
		 *  @tiptext
		 */
		public static function hashToBase64( s:String ):String
		{
			var blocks:Array = createBlocksFromString( s );
			var byteArray:ByteArray = hashBlocks(blocks);

			// ByteArray.toString() returns the contents as a UTF-8 string,
			// which we can't use because certain byte sequences might trigger
			// a UTF-8 conversion.  Instead, we convert the bytes to characters
			// one by one.
			var charsInByteArray:String = "";
			byteArray.position = 0;
			for (var j:int = 0; j < byteArray.length; j++)
			{
				var byte:uint = byteArray.readUnsignedByte();
				charsInByteArray += String.fromCharCode(byte);
			}

			var encoder:Base64Encoder = new Base64Encoder();
			encoder.encode(charsInByteArray);
			return encoder.flush();
		}
		
		private static function hashBlocks( blocks:Array ):ByteArray {
			var h0:int = -1056596264; // 0xc1059ed8
			var h1:int = 0x367cd507;
			var h2:int = 0x3070dd17;
			var h3:int = -150054599;  // 0xf70e5939
			var h4:int = -4191439;    // 0xffc00b31
			var h5:int = 0x68581511;
			var h6:int = 0x64f98fa7;
			var h7:int = -1090891868; // 0xbefa4fa4

			var k:Array = new Array(0x428a2f98, 0x71374491, -1245643825, -373957723, 0x3956c25b, 0x59f111f1, -1841331548, -1424204075, -670586216, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, -2132889090, -1680079193, -1046744716, -459576895, -272742522, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da, -1740746414, -1473132947, -1341970488, -1084653625, -958395405, -710438585, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, -2117940946, -1838011259, -1564481375, -1474664885, -1035236496, -949202525, -778901479, -694614492, -200395387, 0x106aa070, 0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, -2067236844, -1933114872, -1866530822, -1538233109, -1090935817, -965641998);
			
			var len:int = blocks.length;
			var w:Array = new Array();
			
			// loop over all of the blocks
			for ( var i:int = 0; i < len; i += 16 ) {
				
				var a:int = h0;
				var b:int = h1;
				var c:int = h2;
				var d:int = h3;
				var e:int = h4;
				var f:int = h5;
				var g:int = h6;
				var h:int = h7;
				
				for(var t:int = 0; t < 64; t++) {
					
					if ( t < 16 ) {
						w[t] = blocks[ i + t ];
						if(isNaN(w[t])) { w[t] = 0; }
					} else {
						var ws0:int = IntUtil.ror(w[t-15], 7) ^ IntUtil.ror(w[t-15], 18) ^ (w[t-15] >>> 3);
						var ws1:int = IntUtil.ror(w[t-2], 17) ^ IntUtil.ror(w[t-2], 19) ^ (w[t-2] >>> 10);
						w[t] = w[t-16] + ws0 + w[t-7] + ws1;
					}
					
					var s0:int = IntUtil.ror(a, 2) ^ IntUtil.ror(a, 13) ^ IntUtil.ror(a, 22);
					var maj:int = (a & b) ^ (a & c) ^ (b & c);
					var t2:int = s0 + maj;
					var s1:int = IntUtil.ror(e, 6) ^ IntUtil.ror(e, 11) ^ IntUtil.ror(e, 25);
					var ch:int = (e & f) ^ ((~e) & g);
					var t1:int = h + s1 + ch + k[t] + w[t];
					
					h = g;
					g = f;
					f = e;
					e = d + t1;
					d = c;
					c = b;
					b = a;
					a = t1 + t2;
				}
					
				//Add this chunk's hash to result so far:
				h0 += a;
				h1 += b;
				h2 += c;
				h3 += d;
				h4 += e;
				h5 += f;
				h6 += g;
				h7 += h;
			}
			
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeInt(h0);
			byteArray.writeInt(h1);
			byteArray.writeInt(h2);
			byteArray.writeInt(h3);
			byteArray.writeInt(h4);
			byteArray.writeInt(h5);
			byteArray.writeInt(h6);
			byteArray.position = 0;
			
			digest = new ByteArray();
			digest.writeBytes(byteArray);
			digest.position = 0;
			return byteArray;
		}
		
		/**
		 *  Converts a ByteArray to a sequence of 16-word blocks
		 *  that we'll do the processing on.  Appends padding
		 *  and length in the process.
		 *
		 *  @param data		The data to split into blocks
		 *  @return			An array containing the blocks into which data was split
		 */
		private static function createBlocksFromByteArray( data:ByteArray ):Array
		{
			var oldPosition:int = data.position;
			data.position = 0;
			
			var blocks:Array = new Array();
			var len:int = data.length * 8;
			var mask:int = 0xFF; // ignore hi byte of characters > 0xFF
			for( var i:int = 0; i < len; i += 8 )
			{
				blocks[ i >> 5 ] |= ( data.readByte() & mask ) << ( 24 - i % 32 );
			}
			
			// append padding and length
			blocks[ len >> 5 ] |= 0x80 << ( 24 - len % 32 );
			blocks[ ( ( ( len + 64 ) >> 9 ) << 4 ) + 15 ] = len;
			
			data.position = oldPosition;
			
			return blocks;
		}
					
		/**
		 *  Converts a string to a sequence of 16-word blocks
		 *  that we'll do the processing on.  Appends padding
		 *  and length in the process.
		 *
		 *  @param s	The string to split into blocks
		 *  @return		An array containing the blocks that s was split into.
		 */
		private static function createBlocksFromString( s:String ):Array
		{
			var blocks:Array = new Array();
			var len:int = s.length * 8;
			var mask:int = 0xFF; // ignore hi byte of characters > 0xFF
			for( var i:int = 0; i < len; i += 8 ) {
				blocks[ i >> 5 ] |= ( s.charCodeAt( i / 8 ) & mask ) << ( 24 - i % 32 );
			}
			
			// append padding and length
			blocks[ len >> 5 ] |= 0x80 << ( 24 - len % 32 );
			blocks[ ( ( ( len + 64 ) >> 9 ) << 4 ) + 15 ] = len;
			return blocks;
		}
	}
}
