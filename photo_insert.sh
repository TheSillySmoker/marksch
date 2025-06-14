#!/bin/bash
echo "enter file name"
read -e file

mv $file blog/meme_page/meme_images
git add blog/meme_page/meme_images/$file

vim -es "blog/meme_page/meme_page.html" <<EOF
20insert
		<img src="meme_images/$file" class="standard_img"></img>
.
wq
EOF

git commit -a -m "adding meme to meme page"
git push

