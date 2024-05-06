echo "copying sealed tpm2 keys..."
mkdir ${DESTDIR}/rcrypt
cp /etc/rcrypt/*.tpmpub "${DESTDIR}/rcrypt/"
cp /etc/rcrypt/
exit 0
