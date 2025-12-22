#!/usr/bin/env bash

IN_FILE='iban-countries.json'
OUT_FILE='Sources/RFIBANHelper/IBANStructure.json'

if [ ! -f "$IN_FILE" ]; then
echo "Unable to read file $IN_FILE"
exit 1
fi

jq 'map({ (. [0]): { CountryCode: .[0], Length: .[1], InnerStructure: .[2], Example: .[3], Required: (. [4] == "y"), SEPA: (. [5] == "y"), "EU924-2009": (. [6] == "y"), EUR: (. [7] == "y") } }) | add' "$IN_FILE" | jq --compact-output > "$OUT_FILE"

if [ $? -ne 0 ]; then
echo "Unable to process JSON. Is the file contents valid JSON?"
exit 1
fi

echo "Transformation complete. Output written to $OUT_FILE"
