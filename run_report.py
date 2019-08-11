#Import necessary modules
import os, time, smtplib, csv
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.base import MIMEBase
from datetime import date, timedelta
from email import encoders
import matplotlib.pyplot as plt

#Assign yesterday_date_string to current date - 1
yesterday_date = date.today() - timedelta(days=1)
yesterday_date.strftime('yyyy%m%d')
yesterday_date_string = str(yesterday_date)

#sent from and sent to email addresses
message_from = "email@provider.com"
message_to = "email@provider.com"

# Send the message via local SMTP server.
s = smtplib.SMTP('smtp.provider.net')

# Create message container - the correct MIME type is multipart/alternative.
msg = MIMEMultipart('alternative')
msg['Subject'] = "Daily Sales Report - " +yesterday_date_string
msg['From'] = message_from
msg['To'] = message_to

#runs daily_sales.sql
os.system('dbisql -c dsn=prototype path_to_daily_sales.sql')

#Open newly written daily_sales.txt and iterate through it
with open('path_to_daily_sales.txt') as csv_file:
    #declaring dictionaries for sum of store sales and same store sales
    csv_reader = csv.reader(csv_file, delimiter=',')
    stores = {"12":"Edmonton Classic", "16":"Edmonton Jasper", "22":"Edmonton Ellerslie", "27":"Edmonton Sherwood", "10":"Calgary Classic", "11":"Calgary Shaganappi", "3":"Calgary Shepard", "14":"Calgary Royal Oak",
    "1029":"Calgary Britannia", "9":"Victoria", "6":"Port Credit"}
    store_sales = {}
    same_store_sales = {}
    store_sales_last_year = {}
    store_difference = {}
    store_transactions = {}
    same_store_transactions = {}
    store_transactions_ly = {}
    store_transactions_difference = {}
    store_average_sale = {}
    store_average_sale_ly = {}
    sore_average_sale_difference = {}
    store_wtd = {}
    same_store_wtd = {}
    store_wtd_ly = {}
    store_difference_wtd = {}
    store_wtd_transactions = {}
    same_store_wtd_transactions = {}
    store_wtd_transactions_ly = {}
    store_wtd_difference = {}

    html2 = """\


    <tr><td>
    <br>
    <table border="1" width="1700" bordercolor="#000000" cellpadding="4" cellspacing="0">
    <tr>
      <th width= "150" bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">Store</font></th>
      <th width= "100" bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">Yesterday</font></th>
      <th width= "100" bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">Last Year</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">Difference</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">Transactions</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">Transactions LY</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">Difference</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">Average Sale</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">Average Sale LY</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">Difference</font></th>
      <th width= "100" bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">WTD</font></th>
      <th width= "100" bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">WTD LY</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">Difference</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">WTD Transactions</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">WTD Transactions LY</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF", font face= "Calibri" font size = "2">Difference</font></th>
    </tr>
    """
    lastyear = ""
    yesterday = ""
    transactions = ""
    transactionsLastYear = ""
    transactionDifference = ""
    averageSale = ""
    averageSaleLastYear = ""
    averageSaleDifference = ""
    wtd = ""
    wtdLastYear = ""
    wtdDifference = ""
    wtdTransactions = ""
    wtdTransactionsLY = ""
    wtdTransactionDifference = ""
    totalStoresYesterday = ""
    colour_check = 1
    colour = ""

    for row in csv_reader:
        #start colour_check at 1 and alternate between light and dark grey
        if colour_check % 2 ==0:
            colour = '"#bdc3c7"'
        else:
            colour = '"#dadfe1"'

        #Store names
        html2 += """<tr><td bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
        html2 += str(stores[row[0]])
        html2 += """</font></td>"""

        #If yesterday's sales = 0
        if row[4] == "" or row[4] == "0":
            yesterday = '0'
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """$""" + str(lastyear)
            html2 += """</font></td>"""
        #Yesterday's sales
        else:
            yesterday = round(float(row[4]),2)
            store_sales.update({stores[row[0]] : yesterday})
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """$""" + str(format(yesterday, ','))
            html2 += """</font></td>"""

        #If last year = 0
        if row[8] == "" or row[8] == "0":
            lastyear = '0'
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """$""" + str(lastyear)
            html2 += """</font></td>"""
        #Last year's sales
        else:
            lastyear = round(float(row[8]),2)
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """$""" + str(format(lastyear, ','))
            html2 += """</font></td>"""
            store_sales_last_year.update({stores[row[0]] : lastyear})
            #update same store dictionary
            same_store_sales.update({stores[row[0]] : yesterday})

        #If last year = 0
        if row[9] == "" or row[9] == "0":
            total = '100'
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """100%"""
            html2 += """</font></td>"""
        #Percentage difference between yesterday and last Year
        else:
            total = round(float(row[9])*100,2)
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += str(total)+"""%"""
            html2 += """</font></td>"""

        #If yesterday's transactions = 0
        if row[10] == "" or row[10] =="0":
            transactions = 0
            store_transactions.update({stores[row[0]] : transactions})
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """0"""
            html2 += """</font></td>"""
        #Yesterday's transactions
        else:
            transactions = int(float(row[10]))
            store_transactions.update({stores[row[0]] : transactions})
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += str(transactions)
            html2 += """</font></td>"""

        #If last year's transactions = 0
        if row[11] == "" or row[11] =="0":
            transactionsLastYear = '0'
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """0"""
            html2 += """</font></td>"""
        #Last years transactions
        else:
            transactionsLastYear = int(float(row[11]))
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += str(transactionsLastYear)
            html2 += """</font></td>"""
            #update same store dictionary
            same_store_transactions.update({stores[row[0]] : transactions})
            store_transactions_ly.update({stores[row[0]] : transactionsLastYear})

        #if last year's transactions = 0
        if row[11] == "" or row[11] == "0":
            transactionDifference = '100'
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """100%"""
            html2 += """</font></td>"""
        #Percentage difference between yesterday's and last year's transactions
        else:
            transactionDifference = round(100*(float(row[12])),2)
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += str(transactionDifference)+"""%"""
            html2 += """</font></td>"""

        #If average sale = 0
        if row[13] == "" or row[13] == "0":
            averageSale = '0'
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """100%"""
            html2 += """</font></td>"""
        #Yesterday's average sale
        else:
            averageSale = round(float(row[13]), 2)
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """$""" + str(averageSale)
            html2 += """</td>"""

        #if average sale last year = 0
        if row[14] == "" or row[14] =="0":
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """0"""
            html2 += """</font></td>"""
            averageSaleLastYear = '0'
        #Last year's average sale
        else:
            averageSaleLastYear = round(float(row[14]),2)
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """$""" + str(averageSaleLastYear)
            html2 += """</font></td>"""

        #if average sale last year = 0
        if row[14] == "" or row[14] == "0":
            averageSaleDifference = '100'
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """100%"""
            html2 += """</font></td>"""
        #Average sale difference
        else:
            averageSaleDifference = round(100*(float(row[15])),2)
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += str(averageSaleDifference)+"""%"""
            html2 += """</td>"""

        #If week to date sales = 0
        if row[19] == "" or row[19] == "0":
            wtd = '0'
            store_wtd.update({stores[row[0]] : wtd})
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """100%"""
            html2 += """</font></td>"""
        #Week to date sales
        else:
            wtd = round(float(row[19]), 2)
            store_wtd.update({stores[row[0]] : wtd})
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """$""" + str(format(wtd, ','))
            html2 += """</font></td>"""

        #If week to date last year = 0
        if row[23] == "" or row[23] == "0":
            wtdLastYear = int('0')
            store_wtd_ly.update({stores[row[0]] : wtdLastYear})
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """0"""
            html2 += """</font></td>"""
        #Last year's week to date sales
        else:
            wtdLastYear = round(float(row[23]), 2)
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """$""" + str(format(wtdLastYear, ','))
            html2 += """</font></td>"""
            #update week to date same store information
            same_store_wtd.update({stores[row[0]] : wtd})
            store_wtd_ly.update({stores[row[0]] : wtdLastYear})

        #If last year's week to date sales = 0
        if row[23] == "" or row[23] =="0":
            wtdDifference = '100'
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """100%"""
            html2 += """</td>"""
        #Percentage difference between week to date and week to date last year
        else:
            wtdDifference = round(100*(float(row[24])),2)
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += str(wtdDifference)+"""%"""
            html2 += """</font></td>"""

        #If week to date transactions = 0
        if row[25] == "" or row[25] == "0":
            wtdTransactions = 0
            store_wtd_transactions.update({stores[row[0]] : wtdTransactions})
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """0"""
            html2 += """</font></td>"""
        #Week to date transactions
        else:
            wtdTransactions = int(float(row[25]))
            store_wtd_transactions.update({stores[row[0]] : wtdTransactions})
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += str(wtdTransactions)
            html2 += """</font></td>"""
            #update same store dictionary
            store_wtd_transactions_ly.update({stores[row[0]] : wtdTransactionsLY})

        #If week to date transactions last year = 0
        if row[26] == "" or row[26] == "0":
            wtdTransactionsLY = 0
            store_wtd_transactions_ly.update({stores[row[0]] : wtdTransactionsLY})
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """0"""
            html2 += """</font></td>"""
        #Week to date last year transactions
        else:
            wtdTransactionsLY = int(float(row[26]))
            store_wtd_transactions_ly.update({stores[row[0]] : wtdTransactionsLY})
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += str(wtdTransactionsLY)
            html2 += """</font></td>"""
            #Update same store dictionary
            same_store_wtd_transactions.update({stores[row[0]] : wtdTransactions})

        #if last year's week to date transactions = 0
        if row[26] == "" or row[26] == "0":
            wtdTransactionDifference = '100'
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += """100%"""
            html2 += """</font></td>"""
        #Percentage difference between week to date and last year's week to date transactions
        else:
            wtdTransactionDifference = round(100*(float(row[27])),2)
            html2 += """<td align="center" bgcolor=""" + colour + """><font face= "Calibri" font size = "2">"""
            html2 += str(wtdTransactionDifference)+"""%"""
            html2 += """</font></td>"""

        html2 += """</tr>"""
        colour_check += 1

# Create the body of the message (a plain-text and an HTML version).
text = """ This is a test   Header  Header  Header """
html2 += """
    </table>
    </td>
    </tr>
    <tr>
    <td align="center"><img src="pie_chart.png"></td></tr>
    </table>

    </p>
    </body>
    </html>
""".format(colour=colour)

#Declare total and same store sales once the for loop has finished
storeSalesYesterday = round(sum(store_sales.values()),2)
storeSalesLastYear = round(sum(store_sales_last_year.values()),2)
storeDifference = round(float((100*(storeSalesYesterday-storeSalesLastYear)/storeSalesLastYear)),2)
storeTransactions = sum(store_transactions.values())
storeTransactionsLastYear = sum(store_transactions_ly.values())
storeTransactionsDifference = round(float((100*(storeTransactions-storeTransactionsLastYear)/storeTransactionsLastYear)),2)
storeAverageSale = round((storeSalesYesterday/storeTransactions),2)
storeAverageSaleLastYear = round((storeSalesLastYear/storeTransactionsLastYear),2)
storeAverageSaleDifference = round(float((100*(storeAverageSale-storeAverageSaleLastYear)/storeAverageSaleLastYear)),2)
storeWtd = round(sum(store_wtd.values(),2))
storeWtdLastYear = round(sum(store_wtd_ly.values()),2)
storeWtdDifference = round(float((100*(storeWtd-storeWtdLastYear)/storeWtdLastYear)),2)
storeWtdTransactions = round(sum(store_wtd_transactions.values()),2)
storeWtdTransactions_ly = round(sum(store_wtd_transactions_ly.values()),2)
storeWtdTransactionDifference = round(float((100*(storeWtdTransactions-storeWtdTransactions_ly)/storeWtdTransactions_ly)),2)

sameStoreSales = round(sum(same_store_sales.values()),2)
sameStoreSalesLastYear = storeSalesLastYear
sameStoreDifference = round(float((100*(sameStoreSales-storeSalesLastYear)/storeSalesLastYear)),2)
sameStoreTransactions = sum(same_store_transactions.values())
sameStoreTransactionDifference = round(float((100*(sameStoreTransactions-storeTransactionsLastYear)/storeTransactionsLastYear)),2)
sameStoreAverageSale = round((sameStoreSales/sameStoreTransactions),2)
sameStoreAverageSaleDifference = round(float((100*(sameStoreAverageSale-storeAverageSaleLastYear)/storeAverageSaleLastYear)),2)
sameStoreWtd = round(sum(same_store_wtd.values(),2))
sameStoreWtdDifference = round(float((100*(sameStoreWtd-storeWtdLastYear)/storeWtdLastYear)),2)
sameStoreWtdTransactions = sum(same_store_wtd_transactions.values())
sameStoreWtdTransactionDifference = round(float((100*(sameStoreWtdTransactions-storeWtdTransactions_ly)/storeWtdTransactions_ly)),2)


html = """\
    <html>
    <head></head>
    <body>
    <table border="0" width="1700" bordercolor="#000000" cellpadding="0" cellspacing="0">
    <tr>
    <td>
    <h1><font face = "Calibri">POM Daily Sales Report - {yesterday_date}</font></h1>
    </td>
    </tr>
    <tr>
    <td>

    <table border="1" width="1700" bordercolor="#000000" cellpadding="4" cellspacing="0">
    <tr>
      <th width= "150" bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size="2">Store</font></th>
      <th width= "100" bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">Yesterday</font></th>
      <th width= "100" bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">Last Year</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">Difference</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">Transactions</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">Transactions LY</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">Difference</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">Average Sale</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">Average Sale LY</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">Difference</font></th>
      <th width= "100" bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">WTD</font></th>
      <th width= "100" bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">WTD LY</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">Difference</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">WTD Transactions</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">WTD Transactions LY</font></th>
      <th bgcolor="#2F75B5"><font color = "#FFFFFF" font face= "Calibri" font size = "2">Difference</font></th>
    </tr>
    <tr>
      <td bgcolor="#dadfe1"><font face= "Calibri" font size = "2">Planet Organic Market</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">${storeSalesYesterday:,}</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">${storeSalesLastYear:,}</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">{storeDifference}%</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">{storeTransactions}</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">{storeTransactionsLastYear}</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">{storeTransactionsDifference}%</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">${storeAverageSale:,}</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">${storeAverageSaleLastYear:,}</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">{storeAverageSaleDifference}%</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">${storeWtd:,}</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">${storeWtdLastYear:,}</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">{storeWtdDifference}%</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">{storeWtdTransactions:,}</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">{storeWtdTransactions_ly:,}</font></td>
      <td bgcolor="#dadfe1" align="center"><font face= "Calibri" font size = "2">{storeWtdTransactionDifference}%</font></td>
      </tr>
    <tr>
      <td bgcolor="#bdc3c7"><font face= "Calibri" font size = "2">Same Store</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">${sameStoreSales:,}</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">${sameStoreSalesLastYear:,}</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">{sameStoreDifference}%</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">{sameStoreTransactions}</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">{storeTransactionsLastYear}</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">{sameStoreTransactionDifference}%</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">${sameStoreAverageSale}</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">${storeAverageSaleLastYear}</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">{sameStoreAverageSaleDifference}%</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">${sameStoreWtd:,}</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">${storeWtdLastYear:,}</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">{sameStoreWtdDifference}</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">{sameStoreWtdTransactions}</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">{storeWtdTransactions_ly:,}</font></td>
      <td bgcolor="#bdc3c7" align="center"><font face= "Calibri" font size = "2">{sameStoreWtdTransactionDifference}%</font></td>
    </tr>
      </table>
      </tr>
      </td>
      """ .format(**locals())


#combines both html blocks into one
html_message = html + html2

# Record the MIME types of both parts - text/plain and text/html.
part1 = MIMEText(text, 'plain')
part2 = MIMEText(html_message,  'html')

pie_colours = ['#5e4fa2', '#c3a2d9', '#9e0142', '#e2524a', '#fca55d', '#feea99', '#edf8a3', '#a2d9a4', '#75c778', '#6db8c9', '#418ec4']
explode = (0.05, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
print(store_sales)
plt.pie([float(x) for x in store_sales.values()], labels=[str(k) for k in store_sales.keys()],
autopct='%1.1f%%''', colors = pie_colours, explode = explode, pctdistance = 0.85 )
plt.savefig('pie_chart.png')

image = os.path.basename('location_to_pie_chart.png')
image_attachment = open('location_to_pie_chart.png', 'rb')
image_part = MIMEBase('application', 'octet-stream')
image_part.set_payload(image_attachment.read())
encoders.encode_base64(image_part)
image_part.add_header('Content-Disposition', 'attachment; filename = %s' % image)

# Attach parts into message container.
# According to RFC 2046, the last part of a multipart message, in this case
# the HTML message, is best and preferred.
msg.attach(image_part)
msg.attach(part1)
msg.attach(part2)

# sendmail function takes 3 arguments: sender's address, recipient's address
# and message to send - here it is sent as one string.
s.sendmail(message_from, message_to, msg.as_string())
s.quit()
