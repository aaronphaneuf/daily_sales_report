import os
import time
import smtplib
import csv
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from datetime import date, timedelta

yesterday_date = date.today() - timedelta(days=1)
yesterday_date.strftime('yyyy%m%d')
yesterday_date_string = str(yesterday_date)

#sent from address
message_from = "aphaneuf@planetorganic.ca"
#recipients address
message_to = "aphaneuf@planetorganic.ca"

# Create message container - the correct MIME type is multipart/alternative.
msg = MIMEMultipart('alternative')
#email title
msg['Subject'] = "Daily Sales Report - " +yesterday_date_string
msg['From'] = message_from
msg['To'] = message_to

#runs daily_sales.sql
os.system('dbisql -c dsn=prototype C:/Users/aphaneuf/Desktop/daily_sales.sql')

#waits one second after the report has been written to daily_sales.txt
#this may not be needed
time.sleep(1)

#Opens daily_sales.txt and iterates through it
with open('C:/users/aphaneuf/Desktop/daily_sales.txt') as csv_file:

    csv_reader = csv.reader(csv_file, delimiter=',')
    stores = {"22":"Edmonton Ellerslie", "10":"Calgary Classic", "3":"Calgary Shepard", "14":"Calgary Royal Oak", "27":"Edmonton Sherwood", "12": "Edmonton Classic", "9":"Victoria", "6":"Port Credit", "16":"Edmonton Jasper", "11":"Calgary Shaganappi", "1029":"Calgary Britannia" }

    #declaring dictionaries for sum of store sales and same store sales
    store_sales = {}
    same_store_sales = {}
    same_store_transactions = {}
    same_store_wtd = {}
    store_sales_last_year = {}
    store_difference = {}
    store_transactions = {}
    store_transactions_ly = {}
    store_transactions_difference = {}
    store_wtd = {}
    store_wtd_ly = {}
    store_difference_wtd = {}
    store_average_sale = {}
    store_average_sale_ly = {}
    sore_average_sale_difference = {}

    html2 = """\

    <br>
    <table border="1" bgcolor="#fff2cc" font face="Calibri" font size=10 bordercolor="#000000" style="min-width": 1000px; width: 100%;" width="100%"><font color="#FFFFFF"><tr>
    <th bgcolor="#8c2830" class="mobile_td"><font color = "#FFFFFF">Store</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Yesterday</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Last Year</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Difference</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Transactions</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Transactions LY</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Difference</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">WTD</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">WTD LY</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Difference</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Average Sale</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Average Sale LY</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Difference</font></th></tr></font>
    """
    lastyear = ""
    yesterday = ""
    transactions = ""
    transactionsLastYear = ""
    transactionDifference = ""
    wtd = ""
    wtdLastYear = ""
    wtdDifference = ""
    averageSale = ""
    averageSaleLastYear = ""
    averageSaleDifference = ""
    totalStoresYesterday = ""

    for row in csv_reader:

            #generates the names of the stores
            html2 += """<tr><td width="150">"""
            html2 += str(stores[row[0]])
            html2 += """</td>"""

            #Yesterday's sales
            if row[4] == "":
                yesterday = '0'
            else:
                yesterday = round(float(row[4]),2)
                store_sales.update({stores[row[0]] : yesterday})
                html2 += """<td width="80">"""
                html2 += """$""" + str(format(yesterday, ','))
                html2 += """</td>"""

            #Last year's sales
            if row[8] == "":
                lastyear = '0'
                html2 += """<td width="80">"""
                html2 += """$""" + str(lastyear)
                html2 += """</td>"""
            else:
                lastyear = round(float(row[8]),2)
                #testing for same store
                same_store_sales.update({stores[row[0]] : yesterday})
                store_sales_last_year.update({stores[row[0]] : lastyear})
                html2 += """<td width="80">"""
                html2 += """$""" + str(format(lastyear, ','))
                html2 += """</td>"""

            #Difference between yesterday and last year's sales
            if row[9] == "":
                total = '100'
                html2 += """<td width="75" align="center">"""
                html2 += """100%"""
                html2 += """</td>"""
            else:
                total = round(float(row[9])*100,2)
                html2 += """<td width="75" align="center">"""
                html2 += str(total)+"""%"""
                html2 += """</td>"""

            #Yesterday's transactions
            if row[10] == "":
                transactions = '0'
                store_transactions.update({stores[row[0]] : transactions})
                html2 += """<td width="75" align="center">"""
                html2 += """0"""
                html2 += """</td>"""
            else:
                transactions = int(row[10])
                store_transactions.update({stores[row[0]] : transactions})
                html2 += """<td width="75" align="center">"""
                html2 += str(transactions)
                html2 += """</td>"""

            #Last year's transactions
            if row[11] == "" or row[11] =="0":
                transactionsLastYear = '0'
                html2 += """<td width="75" align="center">"""
                html2 += """0"""
                html2 += """</td>"""
            else:
                transactionsLastYear = int(row[11])
                #testing for same stores
                same_store_transactions.update({stores[row[0]] : transactions})
                store_transactions_ly.update({stores[row[0]] : transactionsLastYear})
                html2 += """<td width="75" align="center">"""
                html2 += str(transactionsLastYear)
                html2 += """</td>"""

            #Difference between yesterday and last year's transactions
            if row[11] == '0':
                transactionDifference = '100'
                html2 += """<td width="75" align="center">"""
                html2 += """100%"""
                html2 += """</td>"""
            else:
                transactionDifference = round(100*(float(row[10])-float(row[11])) / (float(row[11])),2)
                transactions = row[10]
                html2 += """<td width="75" align="center">"""
                html2 += str(transactionDifference)+"""%"""
                html2 += """</td>"""

            #Week to date sales
            if row[15] == "":
                wtd = '0'
                store_wtd.update({stores[row[0]] : wtd})
                html2 += """<td width="75">"""
                html2 += """100%"""
                html2 += """</td>"""
            else:
                wtd = round(float(row[15]), 2)
                store_wtd.update({stores[row[0]] : wtd})
                html2 += """<td width="75">"""
                html2 += """$""" + str(format(wtd, ','))
                html2 += """</td>"""

            #Week to date last year
            if row[19] == "":
                wtdLastYear = int('0')
                store_wtd_ly.update({stores[row[0]] : wtdLastYear})
                html2 += """<td width="75">"""
                html2 += """0"""
                html2 += """</td>"""
            else:
                wtdLastYear = round(float(row[19]), 2)
                #same store
                same_store_wtd.update({stores[row[0]] : wtd})
                store_wtd_ly.update({stores[row[0]] : wtdLastYear})
                html2 += """<td width="75">"""
                html2 += """$""" + str(format(wtdLastYear, ','))
                html2 += """</td>"""

            #Difference between wtd and last year's wtd sales
            if row[19] == "":
                wtdDifference = '100'
                html2 += """<td width="75" align="center">"""
                html2 += """100%"""
                html2 += """</td>"""
            else:
                wtdDifference = round(100*(float(row[15])-float(row[19]))/(float(row[19])),2)
                wtdLastYear = round(float(row[19]), 2)
                html2 += """<td width="75" align="center">"""
                html2 += str(wtdDifference)+"""%"""
                html2 += """</td>"""

            #Average sale yesterday
            if row[10] == '0':
                averageSale = '0'
                html2 += """<td width="75" align="center">"""
                html2 += """0"""
                html2 += """</td>"""
            else:
                averageSale = round(float(row[4]) / float(row[10]), 2)
                html2 += """<td width="75" align="center">"""
                html2 += """$""" + str(averageSale)
                html2 += """</td>"""

            #Average sale last year
            if row[11] == '0':
                html2 += """<td width="75" align="center">"""
                html2 += """0"""
                html2 += """</td>"""
                averageSaleLastYear = '0'
            else:
                averageSaleLastYear = round(float(row[8]) / float(row[11]),2)
                html2 += """<td width="75" align="center">"""
                html2 += """$""" + str(averageSaleLastYear)
                html2 += """</td>"""

            #Average sale difference
            if row[11] == '0':
                averageSaleDifference = '100'
                html2 += """<td width="75" align="center">"""
                html2 += """100%"""
                html2 += """</td>"""
            else:
                averageSaleDifference = round(100*(averageSale - averageSaleLastYear)/(averageSaleLastYear),2)
                html2 += """<td width="75" align="center">"""
                html2 += str(averageSaleDifference)+"""%"""
                html2 += """</td>"""

            html2 += """</tr></table>
            </p>
            </body>
            </html>

        """.format(**locals())"""

# Create the body of the message (a plain-text and an HTML version).
text = ""
#sum of store sales and same store variables
storeSalesYesterday = round(sum(store_sales.values()),2)
storeSalesLastYear = round(sum(store_sales_last_year.values()),2)
storeDifference = round(float((100*(storeSalesYesterday-storeSalesLastYear)/storeSalesLastYear)),2)
storeTransactions = sum(store_transactions.values())
storeTransactionsLastYear = sum(store_transactions_ly.values())
storeTransactionsDifference = round(float((100*(storeTransactions-storeTransactionsLastYear)/storeTransactionsLastYear)),2)
storeWtd = round(sum(store_wtd.values(),2))
storeWtdLastYear = round(sum(store_wtd_ly.values()),2)
storeWtdDifference = round(float((100*(storeWtd-storeWtdLastYear)/storeWtdLastYear)),2)
storeAverageSale = round((storeSalesYesterday/storeTransactions),2)
storeAverageSaleLastYear = round((storeSalesLastYear/storeTransactionsLastYear),2)
storeAverageSaleDifference = round(float((100*(storeAverageSale-storeAverageSaleLastYear)/storeAverageSaleLastYear)),2)
sameStoreSales = round(sum(same_store_sales.values()),2)
sameStoreSalesLastYear = storeSalesLastYear
sameStoreTransactions = sum(same_store_transactions.values())
sameStoreDifference = round(float((100*(sameStoreSales-storeSalesLastYear)/storeSalesLastYear)),2)
sameStoreTransactionDifference = round(float((100*(sameStoreTransactions-storeTransactionsLastYear)/storeTransactionsLastYear)),2)
sameStoreWtd = round(sum(same_store_wtd.values(),2))
sameStoreWtdDifference = round(float((100*(sameStoreWtd-storeWtdLastYear)/storeWtdLastYear)),2)
sameStoreAverageSale = round((sameStoreSales/sameStoreTransactions),2)
sameStoreAverageSaleDifference = round(float((100*(sameStoreAverageSale-storeAverageSaleLastYear)/storeAverageSaleLastYear)),2)


html = """\
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="format-detection" content="telephone=no" />
    <meta name="pm-thumbnail-browser-dimensions" content="600x775" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <style type="text/css">
    @media only screen and (max-width:5000px) {{

      .mobile_td {{
        display: inline-block !important;
        width: 175px !important;
        height: 100% !important;
        vertical-align: middle !important;
        text-align: center;
        line-height: normal;
        padding: 10px 0 10px 0;
        }}

    }}
    </style>
    </head>
    <body class="mobile">
    <table border="1" bgcolor="#fff2cc" font-face="Calibri" font size=10 bordercolor="#000000" width="100%"><font color="#FFFFFF"><tr>
    <th class="mobile_td" bgcolor="#8c2830"><font color = "#FFFFFF">Store</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Yesterday</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Last Year</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Difference</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Transactions</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Transactions LY</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Difference</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">WTD</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">WTD LY</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Difference</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Average Sale</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Average Sale LY</font></th>
    <th bgcolor="#8c2830"><font color = "#FFFFFF">Difference</font></th></tr></font>
    <tr>
    <td>Planet Organic Market</td>
    <td>${storeSalesYesterday:,}</td>
    <td width="80">${storeSalesLastYear:,}</td>
    <td width="75" align="center">{storeDifference}%</td>
    <td width="75" align="center">{storeTransactions}</td>
    <td width="75" align="center">{storeTransactionsLastYear}</td>
    <td width="75" align="center">{storeTransactionsDifference}%</td>
    <td>${storeWtd:,}</td>
    <td>${storeWtdLastYear:,}</td>
    <td align="center">{storeWtdDifference}%</td>
    <td align="center">${storeAverageSale:,}</td>
    <td align="center">${storeAverageSaleLastYear:,}</td>
    <td align="center">{storeAverageSaleDifference}%</td>
    </tr><tr>
    <td>Same Store</td>
    <td>${sameStoreSales:,}</td>
    <td>${sameStoreSalesLastYear:,}</td>
    <td align="center">{sameStoreDifference}%</td>
    <td align="center">{sameStoreTransactions}</td>
    <td align="center">{storeTransactionsLastYear}</td>
    <td align="center">{sameStoreTransactionDifference}%</td>
    <td>${sameStoreWtd:,}</td>
    <td>${storeWtdLastYear:,}</td>
    <td align="center">{sameStoreWtdDifference}</td>
    <td align="center">${sameStoreAverageSale}</td>
    <td align="center">${storeAverageSaleLastYear}</td>
    <td align="center">{sameStoreAverageSaleDifference}%</td>
    </table>
    """ .format(**locals())

#combines both html blocks into one
html_message = html + html2

# Record the MIME types of both parts - text/plain and text/html.
part1 = MIMEText(text, 'plain')
part2 = MIMEText(html_message, 'html')

# Attach parts into message container.
# According to RFC 2046, the last part of a multipart message, in this case
# the HTML message, is best and preferred.
msg.attach(part1)
msg.attach(part2)

# Send the message via local SMTP server.
s = smtplib.SMTP('smtp.telus.net')
# sendmail function takes 3 arguments: sender's address, recipient's address
# and message to send - here it is sent as one string.
s.sendmail(me, you, msg.as_string())
s.quit()
