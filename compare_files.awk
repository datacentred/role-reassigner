# http://stackoverflow.com/questions/28459814/comparing-two-csv-files-in-linux#28460330

BEGIN {
    # FS = OFS = ","
    FS = "[,\"]+"
    OFS = ", "
}
# if (FNR==1){next}
FNR == 1 {next}

# NR>1 && NR==FNR {
NR==FNR {
    a[$1];
    next
}
# FNR>1 {
$2 in a {
    # print ($1 in a) ? $1 FS "Match" : $1 FS "In file2 but not in file1"
    print ($2 in a) ? $2 OFS "Match" : $2 "In file2 but not in file1"
    delete a[$2]
}
END {
    for (x in a) {
        print x, "In file1 but not in file2"
    }
}
