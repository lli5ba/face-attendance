import os
import shutil
path = '.'
listing = os.listdir(path)
for infile in listing:
	if os.path.isdir(infile):
		os.chdir(infile)
		for path in os.listdir('.'):
			if not os.path.isdir(path):
				os.remove(path)
		os.chdir('face')
		dest = os.path.join(os.getcwd(), '..')
		for path in os.listdir('.'):
			path = os.path.join(os.getcwd(), path)
			if os.path.getsize(path) == 0:
				os.remove(path)
			else:
				shutil.move(path, dest)
		os.chdir('..')
		os.rmdir('face')
		os.chdir('..')
			# os.rename(path, infile)
		# print(infile)
	# print(infile)