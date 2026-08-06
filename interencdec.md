# Description

Can you get the real meaning from this file. <br>
Download the file here.

# Solution

Here is a better formatted version of this writeup on [picoCTF Solutions website](https://picoctfsolutions.com/picoctf-2024-interencdec).

To get the file: `wget https://artifacts.picoctf.net/c_titan/3/enc_flag`

By using `cat enc_flag` command you get this encoded text: `YidkM0JxZGtwQlRYdHFhR3g2YUhsZmF6TnFlVGwzWVROclgya3lNRFJvYTJvMmZRPT0nCg==`

The first method would be by using [CyberChef](https://gchq.github.io/CyberChef/#recipe=From_Base64('A-Za-z0-9%2B/%3D',true,false)Drop_bytes(0,2,false)Drop_bytes(48,1,false)From_Base64('A-Za-z0-9%2B/%3D',true,false)ROT13_Brute_Force(true,true,false,100,0,true,'')) to decode the text. Originally putting it in you can recognize that it is Base64 because of the padding or magic filter will do it for you. It will then give this text: `b'd3BqdkpBTXtqaGx6aHlfazNqeTl3YTNrX2kyMDRoa2o2fQ=='`.
