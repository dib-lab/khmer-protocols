
sudo -i
cd /root
rm -fr literate-resting khmer-protocols
git clone https://github.com/ged-lab/literate-resting.git
Run test: 
=========


cd /mnt/
bash /root/literate-resting/scan.sh test.txt
bash test.txt.sh
