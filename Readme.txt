Boot up an m1.xlarge machine from Amazon Web Services running Ubuntu 12.04 LTS (ami-59a4a230);
This has about 15 GB of RAM, and 2 CPUs, and will be enough to complete the assembly of the Podar data set.
=======
Boot up an m1.xlarge machine from Amazon Web Services running Ubuntu 12.04 LTS (ami-59a4a230); 
this has about 15 GB of RAM, and 2 CPUs, and will be enough to complete the assembly of the Podar data.
>>>>>>> 9a6b8015f9f82c2e84731057d09dd25fc0b01c24

On the new machine, run the following commands to update the base software and
 reboot the machine:

apt-get update
apt-get -y install screen git curl gcc make g++ python-dev unzip default-jre \
           pkg-config libncurses5-dev r-base-core r-cran-gplots python-matplotlib\
           sysstat && shutdown -r now

Install Khmer:
==============
cd /usr/local/share
git clone https://github.com/ged-lab/khmer.git
cd khmer
git checkout v1.0
make install



Install FastQC:
===============
cd /usr/local/share
curl -O http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.10.1.zip
unzip fastqc_v0.10.1.zip
chmod +x FastQC/fastqc


Install Trimmomatic:
====================

cd /root
curl -O http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.30.zip
unzip Trimmomatic-0.30.zip
cd Trimmomatic-0.30/
cp trimmomatic-0.30.jar /usr/local/bin
cp -r adapters /usr/local/share/adapters


Install libgtextutils and fastx:
================================

cd /root
curl -O http://hannonlab.cshl.edu/fastx_toolkit/libgtextutils-0.6.1.tar.bz2
tar xjf libgtextutils-0.6.1.tar.bz2
cd libgtextutils-0.6.1/
./configure && make && make install

cd /root
curl -O http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit-0.0.13.2.tar.bz2
tar xjf fastx_toolkit-0.0.13.2.tar.bz2
cd fastx_toolkit-0.0.13.2/
./configure && make && make install


Install Velvet: 
===============
cd /root
curl -O http://www.ebi.ac.uk/~zerbino/velvet/velvet_1.2.10.tgz
tar xzf velvet_1.2.10.tgz
cd velvet_1.2.10
make MAXKMERLENGTH=51
cp velvet? /usr/local/bin

Run test: 
=========

bash scan.sh test.txt
bash test.txt.sh
