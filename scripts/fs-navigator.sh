# ! /bin/bash
# Simple file system navigator

function listDir {
	# all files/directories + parent dir
	select fname in * ..;
	do
		if [ -f "$fname" ]
		then
			echo "you picked file $fname ($REPLY)"
		elif [ -d "$fname" ]
		then
			echo "you picked directory $fname ($REPLY)"
			echo "moving to directory $fname"
			cd $fname
			listDir
			break;
		fi
	done
}
listDir
