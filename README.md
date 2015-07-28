# escrit

<img src="https://raw.githubusercontent.com/PatrickLerner/escrit/master/app/assets/images/oldmanreadsabook.png" align="right" style="max-width: 30%; width: 30%;" width="30%" />

escrit is a small Ruby on Rails tool released under the terms of the BSD License (for details see the 'license.txt' file).

### Online Version

There is an online version of the software available at http://escrit.eu/ for people to try, use. No guarantees for uptime, keeping it available, however.

### What Is Escrit?

Escrit is a simple web application that aims to aid you in reading texts in a foreign language you are trying to learn. After setting up your account, simply import a text (from a text book, newspaper or book) into the web interface and get started reading.

Words which you are not familiar with (or which you have not marked as such) will be highlighted in dark red, while words you understand will not be highlighted at all. As you read through the text, you can mark words according to your familiarity level quickly and simply and even enter a translation or note for each word to help you remember it in the future.

### What Languages Are Supported?

The basic problem that arrises for escrit when supporting a language is what in computer-linguisics (or natural language processing) is called Text segmentation. As escrit works on text on a word to word basis it needs to be able to split a text into words. Currently this is done mostly on the basis of where a space or another segmentor is in the text.

This works fairly well for a variety of languages, but is less optimal for others. Mandarin or Japanese for instance do not commonly use spaces between words, and the very definition of where a word ends and starts can be challenging to define. Other languages such as German split words up in certain gramatical constructs using the prefix of a word as a seperate word in a different part of the sentence.

So long as the language uses spaces to clearly seperate text, however, escrit can generally be used to help reading it.
