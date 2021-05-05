# bangoutcerts
Made for RHEL/CentOS/Fedora
For other distros, openssl.conf may reside in a differentr location

This is total crap, and I know that, but it's a quick and easy way oto bang out a CA and a bunch of certs/keystores really fast.

Some day I'll circle back around and make it a 'real boy', but for now, it serves my purpose.

Edit the certz.list, in accordance with the comented line. Hope you don't have any '!'s in you SAN attributes.

./certmacher.sh after that; and lo and behold, a bunch of certs and keystores you can use. A JKS truststore too. Yay.

Hope you have openssl and some version of Java installed.
