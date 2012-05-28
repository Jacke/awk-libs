#!/bin/awk -f

## usage: ceil(multiple, number)
## returns "number" rounded UP to the nearest multiple of "multiple"
function ceil(mult, num,    r) {
  return (r = num % mult) ? num + (mult - r) : num;
}

## usage: change_base(number, start_base, end_base)
## converts "number" from "start_base" to "end_base"
## bases must be between 2 and 64. the digits greater than 9 are represented
## by the lowercase letters, the uppercase letters, @, and _, in that order.
## if ibase is less than or equal to 36, lowercase and uppercase letters may
## be used interchangeably to represent numbers between 10 and 35.
## returns 0 if any argument is invalid
function change_base(num, ibase, obase,
                     chars, c, l, i, j, cur, b10, f, fin, isneg) {
  # convert number to lowercase if ibase <= 36
  if (ibase <= 36) {
    num = tolower(num);
  }

  # determine if number is negative. if so, set isneg=1 and remove the '-'
  if (sub(/^-/, "", num)) {
    isneg = 1;
  }

  # determine if inputs are valid
  if (num ~ /[^[:xdigit:]]/ || ibase != int(ibase) || obase != int(obase) ||
      ibase < 2 || ibase > 64 || obase < 2 || obase > 64) {
    return 0;
  }

  # set letters to numbers conversion array
  if (ibase > 10 || obase > 10) {
    # set chars[] array to convert letters to numbers
    c = "abcbdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@_";
    l = length(c);

    j = 10;
    for (i=1; i<=l; i++) {
      cur = substr(c, i, 1);
      chars[cur] = j;
      chars[j] = cur;

      j++;
    }
  }
  
  # convert to base 10
  if (ibase != 10) { 
    l = length(num);

    j = b10 = 0;
    for (i=l; i>0; i--) {
      c = substr(num, i, 1);

      # if char is a non-digit convert to dec
      if (c !~ /^[0-9]$/) {
        c = chars[c];
      }

      # check to make sure value isn't too great for base
      if (c + 0 >= ibase) {
        return 0;
      }

      b10 += c * (ibase ^ j++);
    }
  } else {
    # num is already base 10
    b10 = num;
  }
  
  # convert from base 10 to obase
  if (obase != 10) {
    # build number backwards
    j = 0;
    do {
      f[++j] = (c = b10 % obase) > 9 ? chars[c] : c;
      b10 = int(b10 / obase);
    } while (b10);

    # reverse number
    fin = f[j];
    for (i=j-1; i>0; i--) {
      fin = fin f[i];
    }
  } else {
    # num has already been converted to base 10
    fin = b10;
  }

  # add '-' if number was negative
  if (isneg) {
    fin = "-" fin;
  }

  return fin;
}

## usage: floor(multiple, number)
## returns "number" rounded DOWN to the nearest multiple of "multiple"
function floor(mult, num) {
  return num - (num % mult);
}

## usage: round(multiple, number)
## returns "number" rounded to the nearest multiple of "multiple"
function round(mult, num,    r) {
  if (num % mult < mult / 2) {
    return num - (num % mult);
  } else {
    return (r = num % mult) ? num + (mult - r) : num;
  }
}

## usage: isnum(string)
## returns 1 if "str" is a valid number, otherwise 0
function isnum(str) {
  return str == str + 0;
}

## usage: calc_e()
## approximates e by calculating the sumation from k=0 to k=50 of 1/k!
## returns 10 decimal places
function calc_e(lim,    e, k, i, f) {
  for (k=0; k<=50; k++) {
    # calculate factorial
    f = 1;
    for (i=1; i<=k; i++) {
      f = f * i;
    }

    # add to e
    e += 1 / f;
  }

  return sprintf("%0.10f", e);
}


## usage: calc_pi()
## returns pi, with an accuracy of 10 decimal places
function calc_pi() {
  return sprintf("%0.10f", 4 * atan2(1, 1));
}

## usage: calc_tau()
## returns tau, with an accuracy of 10 decimal places
function calc_tau() {
  return sprintf("%0.10f", 8 * atan2(1, 1));
}

## usage: deg_to_rad(degrees)
## converts degrees to radians
function deg_to_rad(deg,    tau) {
  tau = 8 * atan2(1,1);

  return (deg/360) * tau;
}

## usage: rad_to_deg(radians)
## converts radians to degrees
function rad_to_deg(rad,    tau) {
  tau = 8 * atan2(1,1);

  return (rad/tau) * 360;
}

## usage: tan(expr)
## returns the tangent of expr, which is in radians
function tan(ang) {
  return sin(ang)/cos(ang);
}

## usage: csc(expr)
## returns the cosecant of expr, which is in radians
function csc(ang) {
  return 1/sin(ang);
}

## usage: sec(expr)
## returns the secant of expr, which is in radians
function sec(ang) {
  return 1/cos(ang);
}

## usage: cot(expr)
## returns the cotangent of expr, which is in radians
function cot(ang) {
  return cos(ang)/sin(ang);
}
