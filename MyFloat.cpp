#include "MyFloat.h"
#include <bitset>

MyFloat::MyFloat(){
  sign = 0;
  exponent = 0;
  mantissa = 0;
}

MyFloat::MyFloat(float f){
  unpackFloat(f);
}

MyFloat::MyFloat(const MyFloat & rhs){
	sign = rhs.sign;
	exponent = rhs.exponent;
	mantissa = rhs.mantissa;
}

ostream& operator<<(std::ostream &strm, const MyFloat &f){
	strm << f.packFloat();
	return strm;
}

MyFloat MyFloat::operator+(const MyFloat& rhs) const{
  MyFloat &lhs = (MyFloat&) *this;
  MyFloat *ptr = new MyFloat(rhs);
  MyFloat &nrhs = *ptr;
  if (lhs.sign == rhs.sign) {
    int dif = lhs.exponent - nrhs.exponent;
    if (dif < 0) {
      MyFloat* place = new MyFloat(lhs);
      lhs = (MyFloat&) nrhs;
      nrhs = *place;
      dif *= -1;
      delete place;
    }
    lhs.mantissa += (1 << 23);
    nrhs.mantissa += (1 << 23);
    nrhs.mantissa >>= dif;    
    nrhs.exponent += dif;
    lhs.mantissa += nrhs.mantissa;   
    if (lhs.mantissa > 0x00FFFFFF) {
      lhs.mantissa >>= 1;
      lhs.exponent += 1;
    }
    lhs.mantissa = lhs.mantissa & 0x007FFFFF;
  }
  else if (lhs.sign == 1) {
    lhs.sign = 0;
    return nrhs.operator-(lhs);
  }
  else if (rhs.sign == 1) {
    nrhs.sign = 0;
    return lhs.operator-(nrhs);
  }
  delete ptr;
  return lhs;
}

MyFloat MyFloat::operator-(const MyFloat& rhs) const{
  MyFloat &lhs = (MyFloat&) *this;
  MyFloat *ptr = new MyFloat(rhs);
  MyFloat &nrhs = *ptr;
  if (lhs.sign == rhs.sign) {
    bool swap = 0; 
    if (nrhs.sign == 1) {
      nrhs.sign = 0;
      lhs.sign = 0;
      return nrhs.operator-(lhs);
    }
    int dif = lhs.exponent - nrhs.exponent;
    if (dif < 0 || (dif == 0 && lhs.mantissa < rhs.mantissa)) {
      swap = 1;
      MyFloat* place = new MyFloat(lhs);
      lhs = (MyFloat&) nrhs;
      nrhs = *place;
      dif *= -1;
      delete place;
    }
   if (swap)
     lhs.sign = 1;
    lhs.mantissa += (1 << 23);
    nrhs.mantissa += (1 << 23);
    nrhs.mantissa >>= dif;
    nrhs.exponent += dif;
    lhs.mantissa -= nrhs.mantissa;
    if (dif == 0 && lhs.mantissa == 0)
      lhs.exponent = 0;
    while (lhs.mantissa != 0 && (lhs.mantissa & 0x00800000) != 0x00800000) {
      lhs.mantissa <<= 1;
      lhs.exponent -= 1;
    }
    if ((rhs.mantissa >> (dif - 1)) & 1)
      lhs.mantissa -= 1;
    lhs.mantissa = lhs.mantissa & 0x007FFFFF;
  }
  else if (lhs.sign == 1) {
    lhs.sign = 1;
    nrhs.sign = 1;
    return  lhs.operator+(nrhs);
  } 
  else if (rhs.sign == 1) {
    nrhs.sign = 0;
    return lhs.operator+(nrhs);
  }
  delete ptr;
  return lhs;
}

bool MyFloat::operator==(const float flo) const{
  return true;
}


void MyFloat::unpackFloat(float f) {
  __asm__(
  // inline
  "movl %[f], %%ebx;"
  "andl $0x80000000, %%ebx;" // sign
  "shrl $31, %%ebx;"
  "movl %[f], %%ecx;"
  "andl $0x7F800000, %%ecx;" // exponent
  "shrl $23, %%ecx;"
  "movl %[f], %%edx;"
  "andl $0x007FFFFF, %%edx;" // mantissa
  : // outputs
  "=b" (sign), "=c" (exponent), "=d" (mantissa)
  : // inputs
  [f] "g" (f) 
  );

}//unpackFloat

float MyFloat::packFloat() const{
  float f = 0;
  __asm__(
  // inline
  "movl $0, %%eax;"
  "shll $31, %%ebx;"
  "shll $23, %%ecx;"
  "addl %%ebx, %%eax;"
  "addl %%ecx, %%eax;"
  "addl %%edx, %%eax;"
  : // outputs
  "=a" (f)
  : // inputs 
  "b" (sign), "c" (exponent), "d" (mantissa)
  );
  
  return f;
}//packFloat




