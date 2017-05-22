(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -ev

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# Pull the latest Docker images from Docker Hub.
docker-compose pull
docker pull hyperledger/fabric-ccenv:x86_64-1.0.0-alpha

# Kill and remove any running Docker containers.
docker-compose -p composer kill
docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
docker ps -aq | xargs docker rm -f

# Start all Docker containers.
docker-compose -p composer up -d

# Wait for the Docker containers to start and initialize.
sleep 10

# Create the channel on peer0.
docker exec peer0 peer channel create -o orderer0:7050 -c mychannel -f /etc/hyperledger/configtx/mychannel.tx

# Join peer0 to the channel.
docker exec peer0 peer channel join -b mychannel.block

# Fetch the channel block on peer1.
docker exec peer1 peer channel fetch -o orderer0:7050 -c mychannel

# Join peer1 to the channel.
docker exec peer1 peer channel join -b mychannel.block

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

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �T#Y �]is�����
�~y?x�m���6������[)vwT�_A�L��$f�ykx�&hw�4}�l�飛�Mt�F�`�_>H�&�+J������8�"��8�Aq�@�����clӍ��j_6����/�{��
��c�O�Ih��G{3�V釬���O�Qѿ�F���W����G*���7ӿx�Nqp9�Q��*�������_������O����_���?��(�_Y�ӟ,�W�/��5��N�
;�����Q���;Z?���{�%�\�w>i<�pG�$�6?k�Z�?��4B�����yNٔK�(M�(M�Iظ�E����OS$����Q��s�O�7�g��
?G�?�?E�(�q},���s��R������ '6d�&�B�z�lC��E�T)M��(�2��I}a,0���G	�;e�ւ6U�	�U���I�ϯ}�`!���h�	Z��Աbc���#��s=$(��!
�ܤu�'����p:�IH��$�L�	kW�ˋ#Y�E�[��Җ(z5�����t��
/=��=ѿ)~��mo9]�~���cx��GaT��W
>��wW����_>��+�%p��'�J����uC�d>���_������� �9ʚ���x��v̐�Ys%�ZD� m.ד����4̸P���5K05�!f-sp%�@"�)m�R{8޹K2�q�pک��+� ���8>@֐��#u�E]���Ev����Q܋�q�jr@1�&��Z=w���A�!⊠dJq=Z�bF#���2����2K;
��G0Qx�T���й������i,����Cq/���\����M������8Zs?*���a�b&d�y�l������[+���
�4��Ym�P<�P��&W� �����$�6o���b�IdB؍�i�v�k���RuN�Um
h����\2T�p7ByWZi�����՝)�Ե����y
 ����L��L��3�;�A��ϼ \���-5<��XR�����u���(��E�$����7�k&@f+��(�t isy�1����V�9)y��@����u��H�b|[$����1���ќ׏�Czķ��ogrȭ&IKj��������4��Er$Ǣ͙E/���L�}X|`6<[�7g��_���4|������V��|��?�^���S���]��2��g��w�w�_j�a�l���zov��yƇ�܎��q���P�i�K*�#��v�
|Hʐ�zGE󫂩�d�e��e�ޗ)��珠u��e��i(��A�ل��,��>/ك�\L��$p�k�jXC"�W���TcSww��yX��a����"�31��������( ͽ���K���2��]�թ� ��TuhM�����)�zKӔ�FN���U {��y����:�q������xH�8�t�=܇�.���|K3ymJ
�(�Hs=]4���Lrآ��F>�>��6s4!��7�8��D���͛X�����P���o�m��D����0��Z<��h�Y�!���&��x}��$�]���]���d�Q
>��?s�����G����J�>*����+��ϵ~A��9&�r��{�t����/��3�*��T�?U�ϯ�?�St��(Fxe���	p�d��CД�4�2��:F����A.�q�#�*���B����Q�E���W.����=qpw4)he�Hc=A]���\���х��V��/��ldcvm+��qC�����l�Zʰo��q��%ǜ�L7�d7���csc��V�p{�nX@�b$�oW�=�������3����R�Q�������e���������j��]��3�*�_
>����?$����J�������7s(|)t�0�7۸ ���?]�f����bX������gb64���������	T8.Sy �Ȥ��O꽩4��s�m��{�;�;Ԓt��$��P�3��m��7�y�ֻ�`�hJEx�3�J��;Y�#��ݓZטBm����lPD$�{�����Y�i�fQ%�S�q�3 ��l(bK Ӑ���3'���|��k�2	]X�7h�y��磅iϞ,�P���I`*�e��w{�χf}yX@�I�F�M���^��Ҳ��h�����j"8���cq)e#���K�HȜ'pr�5CZ�?^�?�/��ό��+�_>����S��RP����_���=�f����Nv��G���������_������T��RP��J�W������C�J=�4/A���2p����t���GC�'��]����p�����Q�a	�DX�qX$@H�Ei�$)�����P�/��C����+���L���z�*�7�[c�`��Ǟ#���~�Ǟ� ���P�;au괒PCCrG��$�W�x=�`O@����0c���������<.���`�ʆ7y��)%���Y��n<��(����S�_���4Q����7��{�;���c���������2�p9�q�������
o_�,.�?��XE�2���8����_����R�;��`���������ǧ�?K#t�������6�26�R��Q��,��x4B��x���o���FQi(������H������|\���Et|KD�X�Ř���6�,�3�)��D�l����z@.�j�uw�9��+>��z"�F����L8�u~�zͥ|�G�|F�D��Nc�;����&���k��3[��ލ���������#���+������S��*�W������A���B�D���C	�i�7�����W^��j�_�=�s�H��(�Z���� �А���>:��$��}�g�=���{P����]P�f�.���4�]"�7�nX��@Cw��ߛz0��á�G&N>��+�|.��#݅��ΈA??$��}�؆Q�1r-����%�������P��Lԉ5����fj�s�މ���{�A3V�t�2֓���ex�L62�gĠ��Ām���N��-�x�s�[SW�m��Dk�
?o@���P�r<��W�T���xl�A�Z�n�yP�:#����\�%[���|t{@�	NSΦ�4o���7�Z�讳��i�9�������mo9� ����^�̤��L��ޚ��>�_Y�>\���BiH�?/�#��K���a��xe������ϝ����{�9������-Q�_�����$P���^
�v���c�v�l�n�%��T�w|v�c���?�e~��P~�(�|�� �[ρ�����<�Z�� 컡�Oܖ���I>�AB���M�u7!�C$�PI����H{�.�}�VzjB��=�[3�c7҄�!�JgL�:M���Tfx@A7��W㸯ƍ��A@OB�=��܇.���� ��Y6h��@]��v#x6�қnҷ��`�6��\��^Jfr��{���,�C�7z}��{���46a�D��h�"������)�_Jq����d�W
~��|�Q��)	������?e��=����V�����������j�����]Y`.��1�~��\N�˭���?F��B���@��+�_��?W���?�|�����Rp��'<¦iCI�b�d	��}�H�'p&@�vq�Q�!֧���u1�a0���[���b��(�IW�?����?@i��-��C˜�lv�C���s�`�J���-�E���x��,�t�V�֕�FwOѽxCq=qh{{�c�F��sh}�
��A~���N���r���	�2�Q_��,6��Yu���"w�'9�/�(�������������4�������������Z���R?�M]?�
�j���Zm��C�kmr��d�{aΎ��$S�ʵ���"��k�����>}�_��I�Z��͹�Z��&N���4����7.��^��q���q�l��}��FH�k��_��|�.����NjWn���}�
�njWy�u�[L~��;?ɇ�}�����?\��dΫ]9������q�W��;M�.Zl���9��/�����Oq;߫�=]����^�µo�:�������y�����eu�좵��Q�����:��t�!�@t����\���غ���"ͮ��kM%��|����dQ������\;�\ξ<�.:J�'ߺ��o^m-���,���`{��ӿ�����ڋ��-Z�j�\�>��fqo���i_��wv�o?�M�v�����]������[�����E�����wj%��*�����8�b{3��ą��f�u�s��v{D�{�����$�e RB�GB�,����}��#�~~ˇ+2��i�,NU�Ȇ��E��������w�F���Y��[X �۪����I���bS�yF�ue���]M�_a�D���	�lW�ْ�N2��=1_�9k��Uy�]�zq���7�{W�:Y��r���C	r9�e�p1�x��CE�n�v�n��7%מ�k�ukO�wb��L|	�7	!~ b������E��"h0ĈBL�h�m=��v���pA�s�{��������{����<�)7�2�B�Y"� c���.������d&K]J�#�0�[۲vL@u�$uD���e8���V��i90���Xti1 ��f��O�9���mB�%�b¸�;�"�ʒ$�tpph|�m�5\����pr��5�!��L�nV)��8Z|ۀ��"&Y2b��h�n�ڨ�;VIp�><άW��w(IP�}F���H�t[��i��-���K��v��;ĻY�3n��2�`�g.��2{hJ#��U)�j�A�a�e����;��Cn��/��
��vI�Э����1�"���`��"yߢ�2@��S�(p�4��6�N}sp��/��������Ofw��h1�N�.�������U�*�z�̅��3���<'�Z����:��ӿ�e�M$�TҀő*�����#�é�e�猞N���"�9�eDi�ssW�kF���we>�W��k�ZS�*��n�9H3���E��ں��.2Y��<+e���)]����{�*wQ�h.P��Q�$
l����7��\sB�VWn�3Bs2��#���\���3�:�d4[PN�+�b��9���s�5D7r�I��6�sR�u�B��x���X��u��e���ۜ�i���i����Z;��O����\-VF�����l���ZT��ۅ�]��v�}�`�ՙ;pr*_ѫ��~8�4��F��QD��
���?�|@������V��q���?��Ps�?��ϻ��+q�(���8��������k-����6Ru�]W5��)�Xdۋ��~?�ƶ�,�X�g�W���Q�U�G8�rzF9�I�{����~�3����[���x�7�/?��K���s�+x���n<AA?s�kƁp�N��;؍�C/޹�s�*��sз�AO�����������}z��}O��)���7�׳�y`D��{Q�K�Y�G�c=:��%�I��9a�\/L�A��-��mf�7
�t��D�T��F�Hn��m�K��bg�Y��D?C�ݜ�����C�+��f�v�r/��|i����;]P�d�8̣X���'�9��-F�%��G��~��݂�0I��F���a�]��=L��~����юp�S��,>^$����YB�tv�W2��TQp�	�T����|��R^�+`XNU[BLHz.%5XHh[%U�)�͇���K�)Nz��R��C�\ڏ�=}�f��LX�	�
z�@��K티�M=u��6��D�����!\�kO͕�u��`�ck�tM�F�xP�*�'����&�e���G�~ee�h.O�B��j�Z�;J��0�m����D�!��$3�0i$]N�L�D�ɰX��'�9d�#<#;V0��x'�	���*�!VI�����.֊�x���|�&��4/^�@�0J��t}�3�r�t3��ۉx��R4���z��ǘȾ�h���>&eY�댲l�3����r)���TJÁߝhpp��$_�h��p�h8��mi�+�|+�Zb�
��b+-_�ʕ�A4���)�Ht^+JT�RU@�4�c�x�%��e����Re��<�+�ѴoHZ��ѭ+r���N$*g=�x�q�T���Z�yw�
�n!A�JFj~$�d��^��t�b	��U�[e�-R��e��,��%��z<C!�V�ˣ$���@HP� ACwR��fn��ya����^jX@�J�(o��ډa�\e�nu����@@N��,a1Y�b��E�@YIo�I�ҙ2� sʲGxFv��0�M�;�a|o�Uk}Z(�L�Y�W��K9o6�s�>t��7���#�}��rmB��<��g(F�I�-G�A��I;f?eq�>����>�j>��)��iN\SPkm^ՠ�@�֮�6�5�����g��_��L0>�.@]���<�Й�<�WNW���ʡ�ڸ\dۜh���N��\�����%r78C���9(%K5n ��n�9�Wڸ$�Nn�	n"F1�4��՚�UC�֦������-��e
�C��IM�dK�	�5[��y�f��X��琳?�n�iu�Y���U��^?a�\ 7
`��j���-������*��6Kf|bZf���=w��E�Q�Ϝ�^����釞�6]�ŉ�j|<� 't p�I_�?9Fֿ�:�G���ס�֡���g��/+�<~��=Zx0i-<H�HB�g*]�$�V������-<(��:"m����`8;4�E�A�΃�"Xu��Ҟ'�8ꂃ�V�Әn֔A�{b��0c	>nzh��;CjSj�W����R��2�p���%�!ъ#��P� 9��
�"Bpd�)�Ѽ��&�tR�J�zq�и�T���*u<F�	�=�#A!m��11���!�GM���c���ajt����D�;X�Uo%���r$ӈu����|~g�P�T�~e�m)�(�l؃�`����o�ol�m�v|��ń`KT�H
Q��k�f��I��[g���K5��K�xx_�p��a�m���]/�n�6ݩ�eʹ<m�Cc�d:��gZ1byv�@w肷Ne�:me��y'��@˽����ct�����a�/��eG�>8��U��Tp�m�$Rn�*�d�u���92P�x�#���*��r���A|&(2����E&����t��,�?=�.�f�!��T��Rv�b�J�`$�����8��
 LxG�p0%�e�	 ^V�$�i����e�;}_N�RBńp�0�����B�Bw;�l��aB�Ɩ�|;����JQ�u%
�6��J]��3�W,�mwD�Q�~�+�*x�����0₳L��٨f�A��lɅ���;<���-	�s.�n�$���\���&qW�^"�}�v^�ò��6��7�8��㞍��䔹���X!��RHn�0��Ep���m6�jb�%d�j�kwT3Z��=�0%�>�h╊�k��v�~��k����BqI��[���S�(����; �R��=G5��?���	�
�ͽ,f׫���ͭ�w|�_��KO=������_��е�~ ��U���5��N�i�D�c��@�'�ݻ���c�?/K�ǳ���'�ݗ�8��_������M}�ɯ�@���I�{q�T|'��ֵ+�_���=���t�Zڀξ������3_l�N��3NϿ^�ͯ�COB�S�5
�#�i����zs����M����6�Ӧ	�4��i�}�ŵ�v@ڦv��N��i�l���~�v�oy��A�\��g	#�0�M�M^�n[D�d<b��[��:�c��{ȟ�8�6EMx�y�[g��O���T�g`�m����#�.��r�^��f��Ӳ����V{Ό=-��`ϙ���6��0g��}�0�r�̹p�a�C��V�m����c$s���5p�蟝�d';��}����%  