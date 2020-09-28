*aggregate industry
gen industrygroup =""
replace industrygroup = "N/A (not applicable)" if (ind==0)
replace industrygroup = "Agriculture, Forestry, Fishing, and Hunting" if (ind>=0170 & ind<=0290)
replace industrygroup = "Mining, Quarrying, and Oil and Gas Extraction" if (ind>=0370 & ind<=0490)
replace industrygroup = "Construction" if (ind==770)
replace industrygroup = "Manufacturing" if (ind>=1070 & ind<=3990)
replace industrygroup = "Wholesale Trade" if (ind>=4070 & ind<=4590)
replace industrygroup = "Retail Trade" if (ind>=4670 & ind<=5790)
replace industrygroup = "Transportation and Warehousing" if (ind>=6070 & ind<=6390)
replace industrygroup = "Utilities" if (ind>=0570 & ind<=0690)
replace industrygroup = "Information" if (ind>=6470 & ind<=6780)
replace industrygroup = "Finance and Insurance" if (ind>=6870 & ind<=6992)
replace industrygroup = "Real Estate and Rental and Leasing" if (ind>=7070 & ind<=7190)
replace industrygroup = "Professional, Scientific, and Technical Services" if (ind>=7270 & ind<=7490)
replace industrygroup = "Management of companies and enterprises" if (ind==7570)
replace industrygroup = "Administrative and support and waste management services" if (ind>=7580 & ind<=7790)
replace industrygroup = "Educational Services" if (ind>=7860 & ind<=7890)
replace industrygroup = "Health Care and Social Assistance" if (ind>=7970 & ind<=8470)
replace industrygroup = "Arts, Entertainment, and Recreation" if (ind>=8560 & ind<=8590)
replace industrygroup = "Accommodation and Food Services" if (ind>=8660 & ind<=8690)
replace industrygroup = "Other Services, Except Public Administration" if (ind>=8770 & ind<=9290)
replace industrygroup = "Public Administration" if (ind>=9370 & ind<=9590)
replace industrygroup = "Military" if (ind>=9670 & ind<=9890)
replace industrygroup = "Unemployed, last worked 5 years ago or earlier or never worked" if (ind==9920)

