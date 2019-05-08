nasm -fbin loader.asm -o loader.bin
dd if=loader.bin of=test.img bs=1024 count=720
rm loader.bin