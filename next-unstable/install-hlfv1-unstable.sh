ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv11/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ,�`Z �<KlIv�lv��A�'3�X��R��dw�'ѣ��I�LJ�(ydǫivɖ�������^�%�I	0� � �9�l� 2��r�%A�yU�l6)ʒmY��,�f���{�^�_}�US9�vL1������˃�mz�t�K�Sx(�L��&�"��%)�.	I1�|*�.�BF̤/!���?�x�+�]rm�PsN�;��Z��h��C����`�PS���8�|��s�L�2\Y3��g�]�Zi�֕�P�X�ֱ��vb�R)
j���0����E~�ϑ��sv{�}@[Uܒ=�e���bې�a�q�|X�M��XZr�֔��cd�A�N��x6�>�����J��RB
�?}�L)o��O�"w��ǝ�9Р�>y���AH�Ť(f��Ϧę���2�Q�����t8��l������G�l�k��i^�Z���خJ���Ϣ�f]����
O�=ݔUl��p�|�\_~	$ܼau�f���:��,��>��Eq� �	S}�r���)��b�V͞!�z�f���N�Z���)�O'���E^f�!%l��<"�Z����"�#��@k�ٸkb����C3ڣ���N�kZ7nrO9nSX^��RB��bOnrZ="��)�����Q��Ai@j������@��&N�8�(B��OQ6ax�NREF��I1s-�����0u�D�u2�!������"D����Hq%��͒$;��E 1Be�9bڇ�x\n�3��=�a�pb�!X1m:hf�#3`�a�hL��R}�r�#?'oΰ
��Oh�i�*��|}pq
�8d���KZ����@��G�t5Osi'»j���퀠���\�n�Xv0r���:��A�E'�S�أ�|�*'����qԗ:Fe_�QB,z��gd�|��B̻L�!�@a�uB�nRs��P�����;#�	� ͝�(k �����cGV8�4�,|��eJ�Zӹ-N��Q����)a��s!����7=�Yy�2��GsyN4N�!�L��A�)A�����fg���IE|�u��b�eٙ�ؚ��~S2=��٦KrHvWm��r4϶	p�����{ٍ��Zyko�P/o6�?ׄ�n|�s?�����OC�Ϯ�h�;�$wE��˅��R}��Q��6ʚ��w i���!Gw�.!��[�B��d��wX���Xw��8#Y	\_of�B�8�[���k�+�����\��M�]H���R��ǆ0�{YH�1���������-=��p�T ��G���T��?B6F��`EBs�Y͡*d�22�n�Q��5��J�@���2�I���b6�|�4�ID'�@��Zy�����Ȧ�KV`Q�wL�\h��ԉ�� ��?��0���??3��)�\���hE�+C�6i�		����Ǔ�oZ�:D
���(=I�@�8O��:
<	;.�<�l ��-[;�]k{�V��5^��)u6Q(ڰ½ͪ<['5׵�\"-�W�nb�!�k��'���3JH�܎iӁ�0��`�隂�� 	̦�cb�gMx�3mՁ�G���!�M�T������=�W@yL1��k4ܦ��jL���v�:pO�P,F~Z��Q�ik�T���.b*6�pH����R\rCjc�#�5	�?�a̯߲4�2�=���瞽��U����F��Ia��/����ow�z�oZ�y����Ig�3���2����L��ƐsoblKjW3
���#8�����,��r������)3��ˉ�?\�n�&YR��8���Lv��~v�w1���ު���ՍF)�����U�ec�TԲ�.:��B:�#�������X�fN�����0u/~�;�g����(��?=�^EN����!+�R"��������r����N��y��*+d��H����Ŕ���%rk��َ��m��mdٚ��b�]�P�8G�`c����o�DO�9vf>Ж�OhzS��bD�G�u�`W%sÊd��B�f}r�����r�	����$�5U|{�/w-}
[c��,��mʶ��$���g�C�Gha��.���jrss�B�@�s����b�[7���Z��f����L��hM�f&}���TT��?�.�v�*��X��9zosn��h-���8�3��r���!��-/�(A�B��-zp>_�.��JϗȓgcN�֖?�h2�~���}�N�D����R}o�|�������� a�R�Y�{ӞD<T�4�b-�f�)�M�Q^��g��d��8��U ��wf����z ������mȻ?�*�'�lJ�zƧ��G��"	C�o�<C�e�]�|+`�Z��=+�Q�'�#2(����YG6�s�5v��
�`a��M�-�1�lr�K�����L� �D�EJ4���<�)�ˤ�^03	�*��FKk��ѱ�w���{�f���?4���(��+l�K{�%P���fa��R^ݔk�ǘ�:VVF����$%=�`�	�������P��mѿ�æ��^�eSM���s+����i0�7��r���n��v���������Y�w�U�y�O$��X��$amz�B�ܦ�I���R�=�^

|�Ez�]����9�h��	q!ΓP5�;��"�T/�/�яb/E����ڜ��M+⬼�rf���/N��?#�/���������a�g�B����
|&���ɇ��O*-��.��˴�����_�Gď:�sPS�P��<	����b�٭�XY����4Fht��X,�͟s������b���Z��L1=[���Z�A]y����ku ��Ơʱ�B�W)*�A�lC
Ⓑ���5_�ۘ��m��y����
no�8���h����sc�G�|�C�-E�9$g`�nˆv$�͵�&�!�ao Z kڮ�u'�yGy
ŀj[v��BsS��M��I��k
�6E4�֗0���z�/���t�ѡ/�������J���7Cei�4];���=M�)6�{�N
X�Ҍ����>!f*gp*t�ڂ���lm"�!;N�5��0��]�tLOW��!f�AyV}|�~�c�jz��b�2r1�#�Bd��
6��1��9�6�$摯?av	��	�eN^�r����B��meQ���0�?��6����ϟ��a+��"u��Hq40{ Z.( (��,j6��E\����{t;����18�1�	�1T���r�J��#eHLla�r=� 1��	x��謅�'@��6a��h���P���R%_�s�I�=����$��'�-���t���ԧ��M����N��c��.Ǆ��7�͂n2�M�j�V_��A�m~����ئC�Z�Fmx�,�m����Q5]|��ʺGo���^'pS��,#�?:���C��}w[����;acv"�lBlˡ,�~��Th�7��8=�PI�Ĉ�$ ϲo��cÑY7Ӧ��F=-#H��~F	��6,S
y��@�W���lP�g5�b���;>��W�CY���#y��	����-3Jw��r�@�R`��@@mIUm�88d	��'���et��u�鹌_�kz$��Ӂ��ॉA���)�1#�$})�%@":�ط�#L�,��7�xvDht�e� ��ZUvb �8�"��G�PÌ���׺^w@ka�C;sO�������>LMjҗ�0%�� d&�a�q�MEv8���f�aH|=�5Y�a�#G��G.�'�}�K���s�I�/0M�g������?�s!p27>���}�$kcu�hB�Ɛ��ͺ��v$�� �u_"��Nr!�y�< ��5��5�AM�@�F 7d���pXN�z��`T��ѳN�t�s�!�	7-��8}�5��/�#O����h�"x�a`"��9M�_P����<ާ=?ƻ��0g�����L�ܝ�Dű�	r(p^L8�ѵi+��5�ᱞq�/j��e���~�B����tV���Kg���)�����q���s��+��g������:q��8��TJ\Zl)�"���V��R��2�撘�2N	8�I-5��)EN-����fv1-6�������nqD��&�^�#\�
�Kd-�tu��F�<�#��E���\��ˑ�\G���+�Gx�Q�]�:q"ߋ�ʕoE���߅!�'���X܀�G~#�� 4T�a��q��C���߳���g��W�ߧ��"ϣq��*�O�&9;����E����י���ҟ��_������ݟw~����������|������})p�'p�ѕ�߽��g�W�G����M��n*�\L�X��TR�f�XH��T��&�%�Ig�&��tJY�8��
��nɋK���p����ݾ�����Z�r�_�E���U��_�����1�]>��r�6�#�a��N3��}��|G��\����oU�6#��~���#��>��$���HɗV�UT(��rAj�h-W)���BA�ݶ�+�v�V����,.n�r�{Kk8��o��Ei=�n?��ol�jEi?T�9=�P�-��j��޽���R��$a�T�W�k�#?xx�t��n�����Ѷ|�R�W�r���}�ޗ?��7�J+y�u�Tj��=�����ꊫ������a�QR*y��H�JcW,y�t@	���~�H+����~-]�(C݀�Ղ:��V���{�vu'/�6$}�Q�Wz%6�r�gw���ݥA��w*��ފD��J=�CH��ƽN�[��zX��Vz`���������Nj���k�n{��[��z�m
S�J����Vz:��A���][7�����T�-��E��km���D!��/.8��G����z�I'q?���^�ɮ�Gn�S�.Z��cWZٸW{P_�u��:G++��-�I��ַ3 ����Ve��	�u~S��%��}{�[��,��@>iw�˯�?�^�G�x�'�J�đd��R�r��^�]�I�)��D��5�'�.��^��1S��Z�3sp�8hu�'�^���Z�ʺTn�~B��w�r�]q��Ң�>�����ط�V��Jq�h���.�W?ӕ�tF>|���֥UcQ:����F�=���n��Z����l%8j�j�D��TkZ%֤��T��ކ�S�5P�Ձ�YV3Kzmr\=�t��H�B:���N�_:��L-ۍ�A��\ջ�����_ٗ�Y��(�@��_��
h�~�+.�W�����(����h4�xggG̮f�m&#�CA����b����nV����\M�s)�m.s����( �$�U��U��ݶ��<-uQ�.0���s�y��t�O��H��{a���v��:1�Qx[����Puէ��W���N��$T1$�aH��]��� s��	3<��#3�����u��c��,�`���lRXEdwKQWp����n�B��%���ږ�q���3�o(��j戈H~�-Cf�����P�V��Y5�V�z
է���/�:%�ʠ�"�����62��0�%=�O�����m�������3b��z�kc��1;]��5�J,�Z�q\�.S�u$��X�\�TT&��e�f~��C�q�3���$��ÚFB��/m���ekO&]��E��W����Co�Aɗ|����*���\XX�+4�֡nG�6-8�q8Mmj�����~}�W��e�?A���hG��$�OaG�t�E��=B�j�����2젙���o�V1�v%��}B�T��g�(�=�=�zx(�=¶�����Co�$�3�%R�۲h��GT,
��i���n��Hsڬ��=@CT��L�����H�Ҷ�~+��fw���E<�<B#?�1��K���s�+r��D�u��6�p�W3�ǈC$2Ɔ�2~k��3�N7h-Th�E�8�q#d�|\��L�v�e�sӭS̆���1�
b��	�v��X9Mh {��=��n��Tx���[�d����K�]�U�����_}���{�Q��[���+���iW�⟠��,t��p8�����`w��/|u𖯎���w���J73	�����'~���}
�����;��#������^*��w���5��0��ׯ��F>�������/ߞ�O��TV��l`��|)*oF�M�ܩ��Ϲ����c~�g�c��л�މ+���1�t�+悞���C�<2��|�\�5ui���PW�e�¶��H��\�@�D1�`}�&XH�m�PX6V9�Ѱ ҫ�G*UjMr�\�M�2� �l��6���ژݫ�)����C2��v�p!�Ѷ�3a�3��iE�i!w�H9��Ӹf��U��
�V��H�CsƬ����4�� k0	�VK
w�]��k��~�L���'�N��"K�/���>������@�U�g&`���7�����t�A`��R���8(&�N��؁"�W��d��!�!;s���-�7��)�d��H�D/�v5?�~��G;�e�$���\���TS���P�7B=l�/�������J��_�+�+{�s��T�#t�U,��S��N	;�����pL�>Ɵ�ŝ�P?vw����ݡ+�?bz7o��*cۜ�5�i!:��{ۏQ��f��I��D{bh��N��f3�U������5��1�Cl��F��5����\-5����7��*C꽥�*BxOw�����p-�9�a��ug��Ks�7�[���Z��Ju��'޺H��e���ǇP���:>'��E����ICF��5�[n�b���Usl�A֩���'�Sk�W���2���,VEo�UI�ϙ��H��!2�aFN#�ey���4�=�'T#	$��@������uj� 4[-L�P%�ͧH����m�'�s�`1�
&�s�`������`ǎ�����c@��=��E�g���85nQɉ��&Q��S�^	"<^\�x&Z��5]�Qa_4�5ah���6�#*9i�睡�M���&����*�(�(�1��P�v�g,�"�-g��r�V8�5_ޔ�Q����W���q�yO�E��@/���˄fo�1�L�`�]z�d6S��������a�A�d�����kkj�
Kn#m���OvF���'��tҥح.�������.���չt;]��t�ӯ�n%�/:i࿆��Ѣ-7�V�ՄqXxu<���@�LFs�Y��4�o
_B_$�hN�� ��i�I�7�_�������������s~}u���u��s�vf��_��Fǚ��9���z�lң�R����o�V�lY�L�������n(�t��~wu�Y7��j}���|t���_�N��on��@^C�}�2��z�L>�W�g�� �Ϙ��ɒҧ�����H�_i�}��޵�w^��C`�>J��/(��9폡(h�T������|�׃ك�8�g�?����O!~�]Hv�I�������5�G����?S|��]�&��x�h�g�?����� �O�w���1��i %���UvGd����������O��R�2� ��?s�G�{���2��r���b�� ��?s��0��r���u�����77'ҟ6����? 8�^�?��/�����6�%m#��a���ܳ��/d�������L���������`�7��/�� � �F.�#��O d�����;`�ȅ�C�K�O ��2��$K ���/[���q�������@^���!X�:r�������?��� T�ն@���T�ʺ�~�B���2�Vr��,��������3C^�, ����`�?3��0���_.r��`
迌�����0��\��3��/[���1�b�?�������"��ej@X��9�=uqǳV&\�*������ٴux��]�>p	�ğÏ���ԑ���K�������o����}_zG�/V_`�,���J�4�'���%�����zЪ���X�P��x4`k��m���[L2]m(3����Nh�]��a��[��tƐʹ�7%�eɬ>!l�Ԛ~E�HdƊ�֝-��/s�N�5z�9��{7���3�!�����!��M��o����_v�����!S��~�7����b���/;|H��Z����J����.C1U+ƴ��X��I��Q�2Z�=���jBg��c<��ռ/+�)�5�RZC�;�	V�l�kJ�bNiY���b+�h���r$�3k��ŕ_�s��/�8����\��!���Xo�է���|���_ �+3��/���@���/����C.�A^�?�/<Z��J�5n�_C��Ue�s��;�(�:�r��������-�l�����wt ۿ;����1�İʼej���ê>7-�3hسn�*���,v��,.��о8_�I6��f�Z�R�X�fi֚/����I��ͳK������r��)+МgWZNo���X_����_�)�=���դ�y�J�IR|}+��bE�y&���%t�����0�� �~���A4ѩ(�F-�A���v:�{L\߲�m�	$Uʻb�+�p_��J�����[���[���bZ�'��Α������ �/|���y�5�h�������``�G����?���
R�P�5� ��?k�G�{�����T�Tx����w�������+����
������_��)!��y�-����/��"�_�����6��}^�\��{����i �����������>��������l����?;���`��|!����_p��S�����y�ȃ�C��_V��������4��9��SA.�������SAz���|�Ą��������������@���Cd����3�0������% ��Ϝ���������i!Y -�����)������ �?d�����_*�^���rC2��/[���	���������>2r�����@�����1���I����?�ҜתÈ1��X�Ȫo(��'��+���q,����ƙ�&δ�;��<���r�)o�e���VxsV��a�,�S"��,�[���HVOE�#��t7,AR���~g���P�:��T�U��KNwF��;��s@�$	�}r@�$	��V�ĭ�C7k����H̆�F��+�3,�N�������L�'�DHOUQo���E��XRs䔆q��6Im��hjlg/�ο3r���{� �� {��Cf	��_��������RB���L�����Ā�O��#���?����������!���/[��������P2u������� �?�������E.������cwF�� ��e�<�?�\��q��i G���8�X�y��Xt�rl��$n#�(\�]q<آ`�#צH�.S�$�~�/�'�<�?F^�������%u�����;������������w��n�B���J�4�7�>���l�{���:"�7�BF��v����+n/����LW��n�EK��_t+KXž�ؗVk<�@☐����,K�l2�/hq�o7�(؊�~`VK��+xފ!粼k�#-�����������A���m��&`�7[�!���r����GfȞ��_���f�Y�D�������-����*vS��� �������t�UTT�lD����H��˶�D�����>)q1R����v��!�0֡�*j�;u�_c��Bv��h;��BZ��d.v�xz��G��{*��/���>�;�g�)~�?�b���� ����/������t�h�L��G��1�g&���n�_}�,Hs�iz%��̨��g˺������ϫ�� �c?\[�������Ze/U}7Y[�3V��"�DC���e*ڑ��]�)֐�t��V��,Bٮ"�~Q]6�Ɉc����<(�y���U�F�W�*���j�*'c����wn͉�[��X5r>\���
�(w�=���o�����=�d:Lg=S5�mHґ���oT���Ri�/�b��RB&��f�k�WW{/���.G���
j��,�Z^b��';�|�S�{�K3F�E<e�H�u���fƋ؋�I�H�����Rk��27T/��j�vHO</��lenV�z�;v�-3�;��¾;a��T�!ٙD��v�i�����?]�����_g��u��	�A������?���/������X��������/���_ ����?�1�,�8��$y;���.M�(bB"�C�~$�	O0dH���(h��<�����A���_Y�����Z%R�̈́ک�b'A��q���o��X�+���[���[nQ�Ѱ���J�����?�q��G�����Lwh�+(�����$�A�I�U�/�S��(@��\t��APa�e<A���Q1^_��X�p��I6�b���,�����O#�S<&���D��Q��	�����<�`���h�$��0�o��!�"���YBN)���^�+�X��}�\�V����������U����٫��z�������������/�����_�T���K��=ޟ���GC����ۜ�K���?E������+����@�����}ժP�!(����a`�#��$�`���G2����{���_��?����H�Z�o`�~�2������?����:���W�^|E@�A�+��U��u��8���ǡL�A��;��x5��aH��B����,�����nu�ބ��~����ͼRj��̙I�ޕ�|/�R��3�.�k^�ѭ�I�L�&ۻ���Y�]�7%�^+v2-�lt%8cc���#k]�����'OL;�:+s��,��M�x.�roT���^����}�G���������e��Vv��?|z5�Y��rz�e{|�a��fEbs�$ر����]C����L��I���)�/��x�3��ޚ�^k��-ҽ��ul����\�m�8 6�1U��^�LB+3�x�ʟj����.I�Ue�KS�J�:����*&�o������^)�D^�����V����p��p;%�Ƚrp�M�YbA�)'�m}T����<��7�˪Ös������y;k.��^�Jn�/�Kc���m#_��.�[��=䲮��ǰ��x{GTW�x\G��;��[C_���ٙ�w���VV�����o��CB��4_A�������ϰ���?#�^���"H|u��4ɾ������������?X��jh5�ISR�ň��|a����/���Ku��s���
����A�����ޯ1]��&Xw���R�Ė�ƥ5�I��񞫓�����k��k�?��[.㣩�9��C*#3%���(K�j���ψ�3R��]���뢤x�$ل:?\sXt��5��������#i���r��ơ!�0L���\�.[�5�����6�������u��)�*�Ԯu��p��Z��g��3Q4o����=7eCԥ�6��K�u���Xn��A�a����6kN���ax0������T�碩x�n��ΰYLV�M�S�/���*hp-�I+�+��QN����-�V��BY��^�w`����C|z�i�;&�爿o�[�E���@�?:��=�@%�����_-��y�����H������@ u������!�g�к��7���+ǑK8�4��e�W����d%����߆�`�"�R�=�����^.�y{ ��p�ϴ	�gڼ� {.M�K�=�pG�:�$��F@X�~���ų�������y%�4Gq��𩯳t���)��m	�X�E�16��: ��=u \P�YC1�S��e�#wZ���R1��lIM�ͫ�C�� ��v�������Ēfr���$�U�Wc?�g��wx��˺8�rⱵ��9�*j�NY/�z۸�%x�
�y���#�.��%yP���e�!�o�_	���v�W��_5�( @L�?��W����?����-�?�������u����y�/�)������_��"����Z�?A\��O96���)��x!�b:�c�&��"�OB<�h<	�����Pi��`Kܻ���?����r���e�+Ŵ)L��=q��Qj��bq\�[i|q{E��s�Gyg{��6����\�2���hDi��ùw��̴)�5R����_yEqp{dJ���ly�s���x�L%sR�2�{+ux��������_��o������:j��0��2���o���V�n|=������W��~L�̩��e��2�ؾ��RY�����^?�M�O���VV�7�����0XX�&�k��v;ѓ��в��Ǭ�:���D�����R�u��d�>�⦿1[�E��i�S�~hmV��Da,�o��
�Q���o�7�_@꿠��:�������� ��_���+��N>��C����,��=��W��R�R�/o��`d�fG^���o��w�:���v�Ю%R��h�8��2�Zw��|���F�86,=���(�5�ƒV�񧺶Kbg`	���,��h߈�ܘ�3�r����Y�y���5}���Z;S-J�ul�����ی��['���m�-��t����r�-]�t�L4��6��PԚy�O-�8�ZO\��N*]����5�Q��΢=c��Y MŖu�;E�Fh��3ID�QDM�D߇��[��� BC��C�J�3J(b%t�B'�|��7A$�|���Fz�P�f�Z3������+P���� ��_E x�Ê�������P�AC�j���+���?D ���ZS@�A�����A�+���pך�J�߻�����H����������j����O8�G��V����_;�����$	��^�a�K����P�OC�?����������C�����x�)���v�W��_��V�ԉ:��G�_h������_`�˿���#���������8�_[P�����kH�u�0���G�����J��[�O��$@�?��C�?��W�1��`�+"���F,FQ��<�%aB�)��!��B��<˧T%�q�!E�	/�4�!���ﳨ�������O$���A/:�/��c��I��3���P�O-��'�fH_Xˤ�I��8�h�Ε�y0��3�X�j�6l��ZRRo=]��Q'���[��!����%c��fz)t��,�A���pjن�o������?
��S����#����?
��$�`�;��"��C�_-A������� ������Wm������@���^m`��<�q|B\Ń&�$�(&N�08��S�����)��"���OR�&�� >�:�����i��P�+��e�MW��Xx̓��C7�453�z�<���x��Oã���I�M��a3G�vK.S��YyTJv�� ��s��yo:#�Y�{*��O�\6���x�͇�v���!��qNW�d�\� ��V�����u ���%��_SP����)�����O���4�?
��������?<*���z�����/H�Z�a9d�����W����������:@�A�+��U��u��E*���G����� �`�����?����P��o7�a7DE�����_-��a_�?�DB����E��<����``�#~���������O�D��r�3�4{1��^������������������ٔ����~���}�[se�'=Z�~��3�D{{�,�F�L�w�.�a�`-�K�h�tW���$���W�g3�7������a-�TvO����OES,���r�	!��Xwk?�d���/6{��o���tl}"���.$fP�g�9K��V��Ɠ�9涒EIVS�q�S��(�<��&-IC�z��@6�[�]��#Cs����`�ÍZ�/� ��@G���W�v|9�������<����G$�L�aJb�����Y��(��O0�	�?��'���U���������k������Q3�o��/�d�����u����V������Co5��)��b�Me��_:�2�(]��wO?1���<)ѹ��ܕ��$R˫;?��rj�D����m��J*/�W���I�����~A�*�p.�!M&�H�f��Ik����UHk�u�/,�Il�n\Z3�4]�:��^�=��?���3)��2>����s?�2�LS��o��>��q�B
����(�(��8I6��O��#g��cß1{�5�|��Hڪ;�����qh�F;L�)cr��o8}g&}�h��1s]�k����<|�~���Z��'���8ES�=y}���l����ၓtI��Nw^��z9Hc=�����f�)�a4:�X|����N�\4O�m��6��J���qJ��E`|�9Y��3�`�{�P8�I3��c���꜓�](�P�KS�l44�~�O�2-p�����o�"�#���G$�!����ݾئ�����k�u��|0��?j��I\�1D�,�0<�<�3��xJG|��1�K�,�T�T��%P��#���A������_9�w���4��~�ݴXlW����"��KQhP�R����&�T�����{O��F����_�%~�dn63��\��m �sxv>���v�M� ������$u��ap�-��9�j�T*U��t{j�g[�q�:p?�^�WOΧ呛*��"���������b����)wm+_����V���6��)3��(���9�Ѻ�Q�x�����m�ϧKO=�;�v��)�s�����ӥg����?�,=�/�������K�A�o���K?��s�����fl|����{��劣�����UU����+e��l�����i&ר~(��	-O�S;�nTwD3_�Ho�֔r��"���'[};S����7S}R:�o:��Inb+͏���I6��^�n��M���3���'J�a�Wh\��?��@z翶���.m�m�m�m�m������lm�'H���goa�'���#���.��������7�Y�\��~ʟ�TRU�z�y���z�$���U����Ѳ#`m~�@�g���HО]z LU�胮\�Z����@���gf[�'�ěS�̜|5��u����E�o��w���q�nWZG�J�M���p�?�T��o��w�[��7�����[W�u�^�/�I��~�}��/��q�y�x���airV�*���%0>#ū.4Ҵx�����~4�P�t�R_�+}F������F�ݰ������߿��ޔ��~�6Y>��r��IX�i�Ϫ�˵ꇓ��{���Rz����qI�>�*�S#b�z_�|Ȏ��iQ+]��k��δ��ugh�g?:_�>�M�7�z*�qz�yw�W|ށP�ǧt��kc������O�f�[��Q�R6GSK�R+���5������٤�8_��ȋ��nV>�N5�6��Tf8ZOcV�GT�X:��rP0��@�6,�Y�Ұ�$F*�����3h�!5h_3�����T���Q
�S��s�#<�����:�B�B*�jF��6����F����)|ی���m�e�9!=�"�it�0��u�a�Q)�G$̱i;'�䝟��^7�b4���=L���e^~ƹ�^�C���?7 �!(V�4��L�☄��3�f �#]S4D$�B�_�h���%�yڵ8_�	9�2��n��j~B�)�H�����
i$�mQ�PˢSl3/�Ҙ��0��ض�!JPԙ��
]���bN�y�b_\�b�k�p���),�����A����f�!x�U������%�9�{�,3
�`�X��P�� �	��п�	N]�y+FG.�(vg�~��:{�7�ɷ��;�L���:P�ڎ��B{�9��`�}�0Z�
H B�ͷ�b�m��i��X;�m�G�g���Š�S���բh�+����<��������~S�.����W� [�](��.�V�}8��I���0�̉�'Z.J!�B�����P �*�T ��>��S	�3�e �(%�i^�_횑(Ng��FE�$*���N,��gӅ�o:�K��p�]�C>�W����#�N������%8�M_�]}hU�c��#ࣨ����u<$�u$�׍(QR"a�!C�q� �TݵA�@Wx��f�k:	O�t�C��)�ʬ��E�^�Έ�c�v(�P�v'��#�������8��qD[���+H7��@v���ȀvkZ@���[x��0��B	�&'N�8�=�,ItB�s+����lr	�1UU.a��x<��aĻ;7@k�������\3+&߱f|z���7���*��dS)�O�ҩ���GI8����2�2A ��В8̂��!�P�#f�L�OH�Qha��*�6Oœ����f$3ƚeh�����b�U+_���Ǎ��A�9Jb)XɛK*����>Ջ b	�^kdZN�Ӌ��
�Gh��A�= 1���oYL2 �xV�YNOK|-��&�]!��k6���>��vi��Mf��y���4�*I�O)���,���������J3鴺�ϲy��9�.�k�z����&$������;dr����Da���!0Шe֥�4V����r����k�Wָ7Z�j8�Z������������ʺnu�Z�S�+�V��>H�������v�}V�7*�)��N�� �s�k�X��g��j��N���g�f�r ���em�J���^����gdbZ�`�]��U 	s�$��:��m)�>X:n���★��,i�	<�z�=����/��G�P��$��B`@�r ؉%��Xlu�B������|�����J���r�UEf?�Տ.�q</P>.���Fe�h�Z:?
�pvY�W��Z�s��M!�H��S+a��4<�v�Qy�f�X󎞇�zb����&��*��	T=n�;�F��vtY�v>6Z'gлO�.�&m�ѐ�SA��\�Y�/
"�K�l��#���;U�R�K�v� �@eP)�Q��8/WJ�O��#����naw/�S%�_��'V̉)�d���< ����Tx��%�9�`Ns2����B��~\#�������w�˗��+��CWو�}	F�O�Us)~�<�j�c���,w�"�@��Es���9��%��R�<o�BS�dM�,Gup^)1d�]"�O��$������8f��t5��ltbk���̦�s���|f���(I��	Z�.BŤF9�/�돰A�;<��S�N�c%�iGRkr��,G�G��$1�uF�SB�u�r��N��5�{��|�Lfvn�@�	K��Z�x�e������uk?�֭�d����lv���(i���]�ٮ�l���?������v��i�$��2�A����@���r�v���ic��a�R͉qȿ����m����O����L6����#��[���.�xl�z�G"��,�!̲L�-Y�������<;cP����!1e��k�
���\~0)6�>�h�vR\��ӭ0�@iӚ�#h'Fw^E%�|�5�;�`;�l7�[��ɿn��u���+MTxB����-9�
�f�Ȏ�Y�[� Z��޵��suDI��( >�4�a��9gո��i�a��wV��O"�5(��vȖ���s���jd�U�#AI�;�}y��>�.��S�?R�aB�Eg��\�m,��c��C�1�����ܜ����m��������(q�uȯ9u}$�)#� �6����������u�4�O0���T���|j����r)�ͥq�'�����c���/_��m�^�&�"�0e`�h�{�_
�CY�#��؀�'�������}��e�@���@%�ǐ���t���up���J�:���]�)^�z�4ywF�́7x�Ԇ�eB����!�@�����b�U�'�&A�
�8��D�Բ�e����؂����Iv^�X�!I��o�M�_
�e'���/@��^��/���f�~�'&0��d�ͿIl���$�d��#�7�Py��W5XlF �c���Y����5�l��2��a/9x���4��G$���à1����<8 Q����x�#Ӝ�"=�����$ ��r-��Jb�?C��#�n�(�q2��Ů@�fu�$@�&W��?�b�:�&��8y����I��ʽ&�]n��<'��!�e�?�,��L�������>���*��w3ؘ��Mh��dM�)�b�V�m�p1�_�5��Ϋ�~	΃!�4�L\��1�Pɺ�$R5����e	:Hܐ(����8$�
��,v9���m�o�^� Z Q>�Eߊ̛�3-���֜�6d����L2)���a���{u `E����+�؉p�O�u|TC��7�o�ۂ�4K���PM5,�-����c��I��{�J�.V��u��un#�[��b3��pn�~�P�2;|�s%"�wɼ�W{NZ{5�����F����s�B׆�HS=�9k7�+p]�����uܘ�z�+����4Gc+�/٣����p�$eq���Z8�Ѿ5R
�L0������Aܰ���(p9_U<�
���2�*��T.|���c�кԂw���pЭ`��@ʗ'��K���[�^�s��K���v�,����J~/����������)��t�eR��=�&�L6���^��wSyJ�i6�����#w�Q����f�d>3z<c
���-5z��V�q�i�w�p������*���lv�^Z�ϙ�A�F�0YIl�z�$1�������4�c���̳��-"�d��?�3C���FG^K�R2�W���]���U�CM,B�̖�biˎ���*�;3��ǳ�T[�t�
���˘!�e�[���6��|44�l�R��K!��p5�s&�����S7FH�Ծ�6-�{��xl�.�f+@��S����O�tz����{��ƨ��I�T�ydS�ħ�G���۴2m(�?�m��?)~�+���L�v����i����tf�����x������������������`n�>����q0��T��	1dKМ�÷)P���f�}�%9�m2'�ێ$i�_o��Ͷ]�+p���)�:���Yܨ��ujaK"�b������m����
؉�4b���y��0e�Sq�O���Js�m\�AGrnaɽ����}D��	��
���N�C������^����p���
эu�.�`?��o��QJt���3�=�%��S2�B����n��=J�q�O������}5]@��Ϣ}q�
T �D�b�7qv���^w>Ϯ+��Ii���T����Is�i���㿩��S�w�؆�@�S�����t���&�"�t���T2���O���T6�C�/��d���1����ƀt/~r��"W�[�T�^��%��;�c� �]��E\2��hB��T�AQ���3�����)"���c�:6���%{d�^�����,2���������R�h�P���V�.�t�jCA�kʂá�ù*�|��"�5-���@�s��K�(,i�/Va�X����~7y чb��k+���y��-��@�>�OP�h\4q+YFƘ���x%�A���#s�P���sd�t��%�����1��SF<�+/"�PRs�=0]]%���]�U�Ӹ����W�u<�����Ϣ�rG݄�@$\�1���xA$��E� i��[���! Oc�k�}�{�tsă��8�uB��� �ZUzj*R1�θ�V�A�U� ���Y^lk�����'�&OV�~#!��	Pr�;��֫���Zx|��"�Z�3��{k�@׼	��^ - �U�J�Vd6��ԳN�/�=��B��op�ac�#�������p?yNþ~
��bS�S<������	˴mA҇m��Vא��Ft���y�tZӐ�g�<�A��*O�:���X|���n�4A���ٳ���������8�r�֨�~d�\#���"�����h*%��}l�TT3-,L0�i�O�XL瑭g���6�R��?�ˉBf�x�"��� F�g(�����n+����ă�"x�6u3�%�״wM��لh�����j1�_R^�N�[��<�*�C��̕d#�|���z���PJ�X���P| i;��}ehg�e��\��!��/�qh\28̂Gp FhF�7�L����m��5 `G�jx�>�=Wn��ٻ�Ǳ�<�;�[{fz�q�mviJ���LlǗx�H�['�'ΕF+'qǎss�$�A�Bڅ�Zм��m�!���� ��
���h� �έR�����N´������}�}|������˫���Û��5�9�<��7�L�!/�ժ�l�5�����u��7)��zm`��w[��.w�c�[6ᵼl��>���e�ڗ���T�z�O��U񃥗����W�n\�k��<���z�f�z'.r�ۋӎ���f���R�'�����-3������]ޭ��<�-�_�p6&�r��p�BRF����?��ϝ&v�9����:E�J΃� �S0�3�fr��j��b��_����l,J��e����:��f߇~����`k�_a�'5�N�����ێ(P7�v��������Y��j�7�������k�����]��e�q��� �!H$����x�m+ �s|�����;�����G���K�����uC�h����R��&V�RѬQ(����!F`T��`u�p�BjdGkQ���6��mp��}��1! �}[z��� ��@o@������_܂�{��E�:�u|��#pgn����W� �����[^����R�3n��z��U��`�NNS'�,Vu�^��Z�w=�\���va���c���'�H0��pt� ����R������7E��[?�����>�ٿ�[_}�/��!�|S�k������s�x�����X��?ĈH4��TX�"� 5�#YkDJ#p�y܁cu
�5<�@Po�Q
mD�_<������՟|��j��?�~��}�'7�)��G�݃~߆�߆�|���0��з�8o�A��:��חD�;���}�1����>��}��/-�M���3ϡsAl�Ͳ��Y����d-ӊF!�JR	�.��)F��-����2G����6\'o�f�h��7�*2���-Q>/_tM��"�]�V*(?�W���O�����Dl˸خ�^�tQ&�ˀ�'�N.�kW�**bNt�ŭ	���*�I�ڡ����s7FϏ%xQ�[����l�:R��Jc1g�1w^!�O���t��UJ�[�F�rĜ���y��]���W��.�V��,-���s�\�d��)�Qa��iC�,��2�F��
��C��;�ү�)d�H-������9t,��K�DȬ��,��y�x�@x�*5�|Nz�xG����؂HW ��.��++���vy&<�{��2����U��C^O�?R���jw[]��B�;MWl�������׹�w�-��t�[���TT^0��>�1�=�6�\e�J�tV���z'�q)_prt܎��^�P2������@n���0� ���^:���l���I�Q�.J�i#�ħ�2ityӒ�$���v�T���URy�Z�&	��2p���>1�ʻn�{e�����{�
.M(ESFF��$���nzLJe��*�q��Z��S�L�N��"i�
͊��S1��7\$�d��rQ)O
C���U���u7�V&-�X�3��_|W��6�sW��tUuD2C�A.m��N���kuA�d0#DM�	LUGgS���XAf�aJ& ����RѰ�:��n���	���K�H��FX�<�"�)9mtc]���+R�(�E1�Uac�b9nH�}Q�w��b>A����H�å%��b'�;��� 9�i�B����c��Y���D����ԈOf��=7=�/�k��˞뉞��� ���'U�����+�Sn5gYbdù8�E&�U)�d�����5�	]��@�F��Q����>���@`���Us�ՠ���v{nWm�2q��+��$⇬v�f��)VU��A��Ȩt{�"u�!n�%��Ǌ�4�cT#>F��pw3C���1�R�)c�G�d�MV��i�s��0Q��gRE�(T�A=p�S�f��v�Q��_0��[xm�}�y�$|:��x?o�p��o�-���	�w�3Vv���X[��ח�;�=�5��,�)���˞my�����e��ғ^^�q�~a}�t���E�gN߹�4���{;/���&�����$��O_;���������C�}�/��K�,=󨬡�|���3��`�Li*�d�L4��32_U��̏qt~%�Y�������p���S~�\�:Z��	�s��h͛��%����.�9��e�)�8�閭|���
�ח�B`���0��Ҵ1�|BffH,A��H��^V��e@Y�4N5�"e:�P�$BF�V�T�N�l��Շ���L�=�6K�r'����,v���
�Y�Lt.��bY�����e�
��NstvS`�'�DXd��B��e�a���:C�u�.4�!�"IG�w�M�\%��J�P1gt
�����9���(kS3[���U�t��he3�O��a�����ց���b-c���5�p���fi���N��v��ʇS�l��G�y�a}E��V��J2,��,��i>���Q+7;#�{O]�DFX���i96��+��H��|�Y�`eN�#"W�Jm~*q�T��^��(��en�ͧW�\w���;���m��잧���Z���p�iBΒ�Y���R,�u�ʦ�h%>TFR��ɶ�פt8d����J���a�ɥ5���:U
񌫾,di;j�m3\�h"_�K����-��BQ��2+Ҵ�ZL�6�ʮХ�Rg"�]]�b�KLƺ���R���l:���)��Ɠ�Q��.���-��T��j�jQK&J�Rh��d�'i
nG�WE>1��o�蜂E�x�d���t�nO]��S-�L��*��w�ə����y霐_�L��(�;r�.�HD(&�h��V�ָ�
�����d[����w��\w	f%L��|�0Q=sl%Lr�:�(`��\��vD.�)�V>˃,��J��q����n���*��g!���M�+Rg�4"V��-��k����D��@+�r�@!�ҏ��o�\UCrCە��8���P[C'un L�)�]m��|�At,�˵���]U�r��d�q`�kH7�,L�(�U��O*�H��\�!&�<��|�ì�R��KT>�Y��ɴ�K#�z�@_�t������M�m}���~N�Xe��Ik����.�ӆ���;�������/���j�fGCt�^�7Ѭ��/���@�C/�{�=B�z�������˛{^�W��m�س�6xu����ZFc�C���ޤK�R���Mp/�[��Ӗ��ju|�,)s}���SuyB���_�����=���.�{��YoF�p����mH��Ev�T��n�'�����ɾ���_���G�
��_��5��*m\��]����8��w+�h�h=�G�"N�<t-?*�N�#��4,c���;���q��.�׼��9]z��GG~d<O"-�s�^����0�W�h3��w�����M}P�nhG<�o�zh���о��}SG��$o���↮���M}Q�:��7�F=��sG=�k.<��>������?Lwm=m���>6�.�O��;��B���Ϩ?'���A�{a2�ˎ�?�5��M���ި��[������(A���" ���l�I���)�2/����J%��
�K���>
-���l'rt3�jL4y�>�Uˣb,G��]�[�!�Tڜ9�ӱ鬋���;��D��A�h����t��ٮ���7���ٰ/i���Mz����D`�m�V�`�^�U���������������쿁1�����/r�����
6��E�MP�'<���HaⰫ�ʡ,�0,��4��a�0k�]P��E8��5)^�����,��mt��tI��s�1;�R�'�YLe�Ь�uX��i�]���T��S<fix��@�ζJv��)TC�:�
�i�K(������M��̍�����1�7#
]������P�@�����[����P^��x���d�x�O�o��,�#��5�g����02����z�/R&��.<��'���o{��$r��р������"e�i�0�����������+���tj��� ���{�G�s���%��U�`�:�K�����?r��?���V��_W7c������$@���������ǂ��[A�/���{��}���O{���������`���$X�-���������s��[�~�����"����?���� ��VD "�?��w=w���������X��m���kl�1��������1�������	��vl{a������+�-ٖ�lK�ɶ���t��_`�����T�4��w���������������� ;�^����g����?��?���&�oGإ�gjӡ�h���;������G�3��q2������	A4�%��!�F�I�Vo��f$�kՐ:Fԛ��zGpL�)��0�k��^��=���#�Y�?��;� ���!�YG#fr�jS���AL"T<�K�$�r���zE���]fQD���Pt��Bh����pUW')�@b�F��a"�&����Ē��c�C 6�ڑ����h=�6�B*�P&�����s�<���i��������8}�� ��ow�������E��yfட��}��������Ǩ���G�\-��\2r��6(���[�K��X{�W�+�/��LC�(f�Vtsp?�� e��#���cX[�hl��R"R�S�B#�21�=u�f��N�l����N�Cuʱ��wU����;���we�2��\�+ν��2����8�����O3t��ߛN���:��*1f̪���޻��?@߂�g����A�Wa��/����/��������,D�?A���?x�����k��-'�v�$�7���3�кR���_u���ߏ?Qת��d��ҁ���f�r�M�-U�7��+д�ꎳ�~Z�n��OZ�zX�d�=J�(��RJG�\�$�E�m��ݠQ���K4I8䢽.���-���k[[���c��z+��FW'Z����)�i�Q��@(S�G��z��}��-�{,"����Q��lu]�ſ��^J>��.�����Q�gg�ݭ�5��}�	-e7���>R��Q�GrfT(�*�Ji������Yז=����?�b�
L�jG�v�O��^�����{��/'��/����N��?`��h�H.����������(H�?����Hp����?r�� �?��G������M�G���	8���@.��m�G���M�G��bf��9���������b�!��_������Q�?�y �����#������s��f�Å���c���0�����0��(|����p��������k�_��"�_�3���X����>xy�kB� ��/��Y���� �����us������_8���_a(���2�P �������O��a1�e!� ����O3����������X����&���Y�!�����D� �E� �����h��o�?.�σ�ǁ����_�?^���o�Fm����ڔ�u'��C�S��j������s{
��:�`�?=���S������n������b���QP�M�>�$��m��î��uôLY�a#3��������e6�k�����n0W,���{u-�75 Ե�j@:��w.}�X�����.c�=�O��)���d+�S�4���a�h�w+�&���1�^����LP�jσ�4O��Œ��������w���ܙ� �XP���搅����D�?g�'俰�$����A���3�������?B�G����_!��C
��_[�����I��!������?B�G���uA��c8��]
���f�]���������;�9� ��y���IQ$� )2
'���@�"�3�,-+���$:�� �%1Td���������� ��9���C�?����տآ�m�g�o���Pm�6����ڼr�ܬT�>΍�f�9���nܓ�RwƯe�9'ҙ����8���;�t8��Ѣ�2�4�����ީt��r���d��];ɹ��ǋ�2��O��C�9&u�,��������h�ɠV�C#�v����Omz�f�~��E}�		�?��,����}	�?���@�C���P8�?��oX���� �����?����~9�Ϋ~۬k�	M���s�Yw�fVuXwTN�|���g�'v+'a���l�$:�h����\əfc PIv�}aHs}ɯ������{��K�a�2��_KL��^n��ʗi4<�y�߯������� ���@������xe������� �_P��_P��?�����XH�����+o��U�ŕ��9q�>��2[������X�_���z �I��{= ��B��u �E�����-Bn�2��R=�S�{Z�,�հ�8�E>)Ԣ��,e'Q�w��k�K���lIZ�k�<.9ۖ��W���g�G]u��Լ�>�<��Z�|�i�WS��`j��W�r��_ u�h d*���/�^#�es�y~]6��_>ҭh�e�Ps�ktN����U.���]�4��f��Bzdվm�C/R�h,�i��@�N�:�T��y^O�s��z�i�ONԋ6���&�W���H%kN�38�>[����8v'ވ�0�H��:�����������	�q���H7�"��X���zz����ߛ�_�(J��q ���/�����Z�$|����\$����7/	RF�/ �H�/_	.�`"3�XF�<��
�]��-����<�Á?�����Ub2�]P���QG���F��w����PݣX	j�����-W�B��l��߯�������C�|4�?�t�"/b�������hA�����n�E���<�/��.�|)�/��H���A��y1P"�giV��@�9%B�䋁С�0(�f�@�߫�ba������8Rk�lo�g�ҧ)c<ٍ�~{����~�Ŷ`Ev:��'�wW~�V�~'�|M+���U����<�?L�"�����q4��8 �_P��__���_��&�;����#�`������b�"�߹�{��p�?$�?F��P��	���O�?���	���7��J��@��4}����� �?���#����x�����0�`��N�)�|i �������0��z�]���� ��/������L ������!&���������y�����"�p���;�T�p���r��ߚʲWʖu�
���5�U2g��m7ͩ�cX�4�z�;=����f7\�������d�3��>fŎ��սe�O�h ��Й�gclk��7Om���k�+�Q��yQ��*��=F�5�{3��ɁQ/��<��y5ʁ����7= _􊤌�C���_5���+�Z�,#�4]^,Ғun�O�j��N��rj��,�mGI�`Ι3�<=Y��0S���;��J����U��e��!4;�xy�0ENdW�\��_�k�KS��,se��Cī~�>�:2)�z�D}������A�YMCe�a�nl�l��R#�����[�]Q㺐O7�xp������4��S�z��#;�WN�yy��3m���Ψ�"/�si���])N�J:	�ѹ����.O�a����j�e���b�u�����=�r#[���g��������?, @���x; ����D���{�g���X@��l| H��ҿ��a�[�߼�����g�Z���iR���f(�6�b����?]�e���s��a*����F�>Kk���c�֙R���'�i�ؽ w�k�,�ճ������c��c�`��׽���ʠ��2^leD�F?nS���b�34��;ژ���{��T��ˍ��2������M� 9�٨1���O�A�W�j��bЗ�/��ڨ�Iw6li,��\���d����Ǽq2�1������&�P��8��zok���/{��sU���.ϳrwaW���vc��4KS�]����m�ꆁ�Z�]�����5���n�����2:VmëXn�O�HU�x��F!/��"��t=.I�%������ʡ2)�V��f��O�Muc$Ȱr[��]jطkmD�N^��먟���W@��c����/����@1 �����/������X@�?��� | �������o���~=�/}?�7��Q���gL/;������-�����>ڃk��7 �Lm�� ��@�_� ��Ǟ6��6��P�A��4:�����R}�5�Y3�ͤ�����P�6ʠ�.&��MY{XWg[��,��z�w��Diw�I��W|;@=ޓ��5*UT���x�s8[l��k-���9HK̹����>�=�Tk^i1�ި*bȬx!�V�yz^]��2;	\V�aQ��aSR�ҩ-��0[��L��^k��	�(ZDQeu�ŕ�Y6�����]�����������_�� �	��������?�����_�����2��p� ��Oi�م�� �����H���{���, ���"}:�D?�I�h9��0
x_��B�Dy���� 1����R�L�{?H��{��������F�V�lj�ͬ���H�[j��2��1��aY����i�kv�4���;TR�s:��-�UT�J�>��,7%?�)���NnG8	�e(x�k���t��6�}�ņ,
Բ��OM�֣�U��Ӎ]��o�
���Y
^��%�
��Ł����� ����.6���A���+��������˫�u#��R3
+�y{r�2�cvRc���_/\d�}w��|��cw��5�-���4��d��9V�m��5�1��Qr4�m{k���&�0����׷�y{j��_�?�����?@߂�g��H�A�Wq��/����/���������,D��?�������_����]�i�M��*;q���� k�{������i������N����dq_R���K��n��rI?,���wk�ď��S��fV-��n����x ҝ�4�Nܘ�s�|Δmĥ�s�5c1��|��CNj�����v���J_{�?ܺ�5��zU-���{a��FU��u�\��7�Z,Rk�8n��y�k�/3�lW��*�d�r�-��J�k����jnŪIG��*�==��?��L�X*����<���~����b�Pg��N8f�4��b&�b��&��n�6J�~�-��:�����V����w����3|��#^I�����}'��A�����������J*�������� �]��?4w%�����_9���0����W��Z��o�p��	x��x!�����#��Y���A���0�(�����9��c��!��������q�F��
��_[�������v��/D��o��� ������W[���ߩ��A���ǯ��O.p���������c 	���w��A�/`�8�'�������������!������������	X�� _���4/��M6�)!Q�P�eQ��޵w'�d���u�}�tONEsof]@T�����Q�C4��|��M41�t�D�i�Y'-E������E��h$�be���l2,L����0:�����O��������z/ͻ��l<�PD�P�^���Z��kw=�>S�2v3��h����\�v���TmK*I���]�-�|}n��NR�Y��W��u���L�/U�]*W�;B�:N��g���o�S��S��2��A��ᆏx	�D���3�������)�?�����x�� t(�����&
����I���x�_��/��w��?�������С�?��d�� �%GlVK!�`R����
5Yͱٔ
3Y2;�U:��
�d�Bj�/|����/���8�g�?���gX��M��;���%Kա����_�6������s���]f�wƎ��`���4�*�9$j�U���v�Ij0�[)���Ku*����`�轖36KB�&spq#�0�'�|�+������G��8K���T���3�*��A����'�O��:����<-�b�������,���@td��?yd��?����j��O�9� ��_�8"������?�,������?~?�t(����(:^�?��?��?��?��?���s�c�����	����߆8����m���G�������������� ��)�������b�� ���:��W�v�Tg<n����i42]��o�������}��m����[U���{�5���(u��8P�����?j	fU�S��]k&�	JN��B_g��<���y�T$^҃�p��g��R?3b��Q��.Z�L�V�н'v�{�U� ����B��r��Ox�H6���?��n|1l5�1Wf�tOe:��,&��e����xZ�_��Z�(�E��\���3���%��eш	�\�\
���I9a5L��^�7��W��0����b���������>~����(��m��$�?�'��� tZ��uh:���O���������������������#�[?vo�z�����w���G��������?������^]��������oq5�n�j�+-�W�k���l>���^�Un�����U��=׊�h�#Lkc�hΐw��}qY�p������=�/꬀�[�~@e��we�;b1�ދ��f<Vnxw�NO�\���vD�6&*����X�U;jP�HT�#���D�q�$L#7iD�+8��b��
e<�)����<����G)�!��9R����-/�f�8]�;՞]Y��cP�O�^&?&���5_�*�~�5[��@.s催�#]e��p䳵6+�U���qUԃ���+U�)؇�Gk�xlKz����z��s���M8�*���/�iU(s?s�����#�Ve�gw�Y��\�;�P�T�:]bdٯr�C���	�sU�+HM�q��!����@&+����\rl�ټ��m��z���%uIo��{V�^iv��(�뷉�^�ԐIc%09v�պ-.^��t�_j�����B'`�M���l���(��m���~"��_��:%��FJ�UG锦����Φ&�&ӹ�I�(Y�Uլ��Zΰ*E+*I�5M�h��d����S��}�����a�=��w�+��di�v#YH�2�k�مs�[�g\�^�I�zs�+Ea}�3���ւi��8�{�aN,wW��O	�"1W���f�h.T��,ZP\���.�|�� +hk�<�����[��$k������)�����ǣ#���/��Na������I�|�����?*7���cw�/H�����w<zO�ϯ5Ŏ_�V_g�6�[�7�e�ӊ#��d8���6tm���:S{��H�\[���ܼv]����mC��!�:��]�����^�|e|i�w��Y�	\��o�Yf�e������i��T�=�����	��w��:�����_ǣx�W��+������?��w��Ol�N��c�g�����C�k����z������xE���?�a+�|J4��������(���s������r	dm��� "L�{ �m{v� d��Ş�N���*�7���k.F6�ꖹ�yų��mQSr:tFD㼐��ׁT)X�v;�*
�*u��Z�
[��D�M׮e%�� 7D�[ә�j�5��C5 �as�}���M�������f��U����7yÆ�:%s���7`����y%����k���]�fk7u�]wkL��V=:���W�s�`���F
�5%�M���N���MA{e����B2����*>�K�aFy�bvftw�c��^�~sIض띕@g8ӛ������l�/�Z*�_M;��w��9�O���j���e�]�������{�r}����+g� �i�NsA�r�%�O�'�n�o.*�
-^H�<cd@�psY�*A�|(����vVw4脦�{.@����G��6@�L�dݰt�>,[��;Wi�>� ���[��/@M��˭ ��3ٰ.�����w٘�Y{�p��Fd@�@����� 5&� @�b��MX���'�zV�9k�yA޴��R�-��MM>J~�ԇ
o��Qr��-�ƿk����ol���j( ��%+&D����4T�C*�-Bc$�.0,��}g�/��}'�� U���]�e�$Ё��d�ic�a�'l6@5�- ;����DT/�1��x�hxL[�]W	e������������|Á�W��ڏ/�F�,�WF���������#�>��H6��CȐͯa]�=歛���md�8�1�<0�%��PC��W��e��~�F��e|��cߥ�?�Hl��[]E�����w�c���x(/*��B6}���c����6?�F����	�к�߁�9�4W��-�}:�#�Fi�,s�Pʳp��VS�G�X�;��e���Pԅ"�H�
�|�d��[%Ev^H��8p�h���2���'�P�v $�Ucf;p%�XF]�.U�Zi���|l�ɦ�Z3O~Ё�s-1m{��S��t���Y���G�}˻Hm�n`�h�[=�%����4��3!�>����&6�=<U���K_]�[7�A�}<��TM��^��ʗ�M�`�F����X��`�;Ʋ=0�=w��]�E+6�;���k~kHwCN�t��PǼ�օ��<v:+��iGF}��r�_Xy�6M��l?Hr:;�a���%�n�� ���2���o规���7�c-&�N]<�}�.����#�xn���{.�E���i���b�������}2@�8�?�������0���|[����dR����0����9:� �:�.����Ğ`�'��@��[�p+���S�����(����.�=2��*�%g�oQ1�(���}�7mu
�u�G�
��}��X�,hnX	!\�;�m�j��$l~Ky���N9~0������a�=]'V>��f��(��0��`*M��X�Ax���t	~�~#,�
�9d�A���b�dM���:&�t$k�Q���\K(!k�L0afh-Ƕ�C�gـw[�Wū$���^vk���`[l���U��=�%>}�)�/H�7�Y�|�T��T?V�LQ�<����e%��((�iH�G��HU�(����,S
���Q�2RF���0Y(S�֝a�a��
n��d���"���z	�1E����Dv5��nj�on����xN���X�r��Iˊ��L�d5YKQ�QI9'�r&�� Kf3YHˊ���iԓ�dX��32D.7x���B�-썅m�3��]�_�V���[[���й���}R�2����5���{2����'ަ��V^l!�.�5��Un+�bE쉕+*��r6��k\>���+2��bn�o[jW�N�����Z��굱^�,^n��U�톔�Z[,����y���
�p�u��!��v��W���$������썓��&u���J(K��jWi����EG*Nb='�	v$���t�];�v5�~X��R�m�_gp�{�w��R��*}��B��}�WD?�6y�-yQ�!+W[O=�/�8�&��9#�ȋ|����W�k�F]�u�|�X^&�IgI.d'���ڶJ���>��E�����h����#��n��PF����P���mM���r��j�F��N�n�;������1J���n�3��~P��A�E�l��u��o��p<��������w���P���6��6���5�2��2猪�6�(N�X�r9�j$�.|A�S���.h�B���Bt�+S^��ጟ��>�,7\��+᭐�����[d�>t�K3%��	F��?[��}n6,�"Γ���(�{�(��v[T���L�9L6�@�%g��nq�̍}���A����*�7���xe�g*����Q)���T
�hd����!��$�J*�;Ưm�K�$f�����c;���cX�Ms�nn��k'p���C�x�@���@�����02}1�;�\td%�v�����M�(������>��?�N����?ėn��nK����og����_�<��/̶=�+$�!�|8�>j��:��r=�yx��P�Â�@�~;{��J�j
v��b��=���QeޔW�ׁ3{-j�*�g�����d�>a�3�N��hE��h�ZA�v3;P�k��_�
'OMQE#�������>ٹ	0B�\�}Ō��l��p�4 Մ��K�������z��g��k���Lx�{�E�O��*��1��N �3�Kٳ�=G��
 �B����	ϲ�	��8'�o����+���pS@������GF_h��,� *���?�����^����W�^q�:�ku�i��ak�� ���=2�6
X/Y��-�D�!���?>C�-��9i���_���q̣���`
.
	���˗����_qY�?ۻ�޴� ��_1�"���رS���C�K[)j_�<,�P7��H�wfw}�M�Gz��B�wgg��p6:/��/����*Tqr'�$�mR�ݴl�ȼ��dIn�Y�Z]G�bC�w��	����:L3�2��;w����x��1��2������]�{_>˛�L(��)�`�J$_�83V�I� oH���qh>�0�>���ǖ�/p~�޿��p���䒦iY�g�Z��� ��M}q�1���4��7.S��A��� ;N�S�S�F�24���$��H��H3�"/6��Jx��u���P��b�!���/�[6%��3�g�+��[��k�s����o��߾��&/��:����︶mm,��,�|eU��울������S���Ǔr`���`d=ߵ���G�7���w憮���Ci�g��{�?pzR���uzT���޽p��Ƈ�h�E*Whh8a��Z3���s���q٧���a�z�wg��,��Zq�)��*�A%@�ut����G'`-������:[|���-΢�j"�k*W�e=@�ɳnYoH�WE	M��pf�����L�̝�8��K�k�ځ��ߙ�U��xg��T������~4��5^�1���G�÷s_�<�����(�G�}�Z�OrrA�Ț^#��;k�ZA\ � \�v1���,:����l�f���_��:Lj5.�����.�>WL��#���cDsk�r�T?�'�p�8a��=�1m��Lb�Ϝ�Aq���d[G	����L2��`0��`0��`�5���Kz 0 