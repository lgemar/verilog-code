#!/usr/bin/env python

import math
#turns a string into a vaild bitstring
def bitify(x):
	try:
		if not x:
			return "0"
		return ''.join('1' if bit not in ['0',0] else '0' for bit in x)
	except TypeError:
		return '0'

#extends a bit string with zeros up to length n - does not truncate down to n
def zero_extend(x, n):
	x = bitify(x)
	if len(x) < n:
		x = (n-len(x))*'0' + x
	return x	

#takes in a bitstring, sign extends it until it is n bits long
def sign_extend(x, n):
	x = bitify(x)
	if len(x) < n:
		x = (n-len(x))*x[0] + x
	return x

#return one's complement of a bitstring
def invert(x):
    return ''.join('1' if bit=='0' else '0' for bit in x)

#returns two's complement of a bitstring
def twos_complement(x):
	x = bitify(x)
	num_bits = len(x)
	if not num_bits:
		return "0"
	y = x
	if int(x,2) == 0:
		return "0"

	y_int = int(invert(x),2)+1
	if y_int >= 0:
		return zero_extend(bin(y_int)[2:], num_bits)
	else:
		return sign_extend(bin(y_int)[2:], num_bits)

#converts bitstring to hex
def bin_to_hex(a, b):
	a = bitify(a)
	fill = a[0]
	y = hex(int(a,2))[2:]
	hex_length = b/4
	if len(y) < hex_length:
		y = (hex_length-len(y))*fill + y
	return y

#converts integer to a two's complement bitstring
def bin2c(a, b):
	a = int(a)
	fill = "0"
	if a < 0:
		a = twos_complement(bin(-a)[2:])
		fill = "1"
	else:
		a = bin(a)[2:]
	if len(a) < b:
		a = (b-len(a))*fill + a
	if len(a) > b:
		a = a[0:b]
	return a

#converts an integer into a twos complement hex string
def hex2c(a, b):
	return bin_to_hex(bin2c(a,b), b)
	
#converts a bitstring or a hex string to an integer, assuming that the string is twos complement
# set radix to 2 or 16 (for binary or hexadecimal inputs)
def int2c(a,radix):
	if radix == 2:
		a = bitify(a)
		max_val = 2**(len(a)-1)
		num_bits = len(a)
		if num_bits == 1:
			return int(a)
		elif num_bits > 1:	
			if a[0] == "1":				
				return -int(twos_complement(a),2)
			else:
				return int(a,2)
		else:
			return 0
	elif radix == 16:
		num_bits = 0
		a = a.lower()
		bits = ""
		for c in a:
			if c in '0123456789abcdef':
				num_bits += 4
				bits = bits + zero_extend(bin(int(c,16))[2:], 4)
		return int2c(bits, 2)
	else:
		raise Exception("int2c only takes in binary and hexadecimal strings")

#test suite
if __name__ == "__main__":
	print "testing bitify"
	for x in ["101001", "100_2323_111", "", 33, [1,2,3], (0,1,1,0), {'asdf':2}]:
		print "x = %25s, bitify(x) = %25s"%(x, bitify(x))
	
