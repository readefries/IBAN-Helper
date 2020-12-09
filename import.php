#!/usr/bin/php
<?php

$IN_FILE_NAME = 'iban-countries.json';
$OUT_FILE_NAME = 'RFIBAN-Helper/Assets/IBANStructure.json';

$in = file_get_contents($IN_FILE_NAME);

if (null == $in) {
  echo 'Unable to read file $IN_FILE_NAME\n';
  exit(1);
}

$json_in = json_decode($in, true);

if (null == $json_in) {
  echo 'Unable to decode JSON. Is the file contents valid JSON?\n';
  exit(1);
}

$out_object = new ArrayObject();

foreach ($json_in as $country_array) {
  $country["CountryCode"] = $country_array[0];
  $country["Length"] = $country_array[1];
  $country["InnerStructure"] = $country_array[2];
  $country["Example"] = $country_array[3];
  $country["Required"] = boolval($country_array[4]);
  $country["SEPA"] = boolval($country_array[5]);
  $country["EU924-2009"] = boolval($country_array[6]);
  $country["EUR"] = boolval($country_array[7]);
  
  $out_object[$country_array[0]] = $country;
}

$json_out = json_encode($out_object);

$out_file = fopen($OUT_FILE_NAME, 'w');
fwrite($out_file, $json_out);
fclose($out_file);
