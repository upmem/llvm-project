int foo(int x, int y) {
    int z = 3 + x;
    return z + y; //% self.expect("frame variable -s", substrs=['ARG: (int) x = -3','ARG: (int) y = 0'])
     //% self.expect("frame variable -s x", substrs=['ARG: (int) x = -3'])
     //% self.expect("frame variable -s y", substrs=['ARG: (int) y = 0'])
     //% self.expect("frame variable -s z", substrs=['LOCAL: (int) z = 0'])
}

int __main(int argc, char **argv)
{
    return foo(-3,0);  //% self.expect("frame variable -s argc argv", substrs=['ARG: (int) argc ='])
}

int main() {
    return __main(0, (char **)0);
}
