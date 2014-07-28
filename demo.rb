require 'selenium-webdriver'
require 'rspec-expectations'

#========= Start of function and classes library =========#
def mouse_over_and_click(element)
  $driver.execute_script("if(document.createEvent){var evObj = document.createEvent('MouseEvents');evObj.initEvent('mouseover', true, false); arguments[0].dispatchEvent(evObj);} else if(document.createEventObject) { arguments[0].fireEvent('onmouseover');}", element)
  
  $driver.execute_script("if(document.createEvent){var evObj = document.createEvent('MouseEvents');evObj.initEvent('click', true, false); arguments[0].dispatchEvent(evObj);} else if(document.createEventObject) { arguments[0].fireEvent('onclick');}", element)
  sleep(0.1) # Since script execution is very fast this will help slow the execution for mouse actions
end
def table_Element(column,rowNum)
  if column == 'Delete'
    element = $driver.find_element(xpath: "(//div[@class='x-grid3-cell-inner x-grid3-col-col"+column+" x-unselectable'])["+rowNum+"]/div/div")
  else
    element = $driver.find_element(xpath: "(//div[@class='x-grid3-cell-inner x-grid3-col-col"+column+" x-unselectable'])["+rowNum+"]")
  end
  return element
end
def enter_textarea(text)
  $driver.find_element(css: "textarea[class='x-form-textarea x-form-field x-form-focus']").send_keys text
end
def enter_text(text)
  $driver.find_element(css: "input[class='x-form-text x-form-field x-form-num-field x-form-focus']").send_keys text
end
def select_list(text)
  list_elm = $driver.find_element(css: "div[class='x-form-field-wrap x-form-field-trigger-wrap x-trigger-wrap-focus']>img")
  mouse_over_and_click(list_elm)
  listdata = $driver.find_element(xpath: "//*[text()='"+text+"']")
  mouse_over_and_click(listdata)
end
def find_by_id(id)
  $driver.find_element(:id,""+id+"")
end

# Invoice Table Class -- Start
class InvoiceTable
  def initialize(rowNumber)
      @rowNo=rowNumber.to_s
    end
  def item(text)
    item_elm = table_Element("PriceList",@rowNo)
    mouse_over_and_click(item_elm)
    select_list(text)
  end
  def description(text)
    desc_elm = table_Element("Description",@rowNo)
    mouse_over_and_click(desc_elm)
    enter_textarea(text)
  end
  def qty(text)
    qty_elm = table_Element("Quantity",@rowNo)
    mouse_over_and_click(qty_elm)
    enter_text(text)
  end
  def unit_price(text)
    unit_price_elm = table_Element("UnitPrice",@rowNo)
    mouse_over_and_click(unit_price_elm)
    enter_text(text)
  end
  def discount(text)
    discount_elm = table_Element("Discount",@rowNo)
    mouse_over_and_click(discount_elm)
    enter_text(text)
  end
  def account(text)
    account_elm = table_Element("Account",@rowNo)
    mouse_over_and_click(account_elm)
    select_list(text)
  end
  def tax_rate(text)
    tax_rate_elm = table_Element("GST",@rowNo)
    mouse_over_and_click(tax_rate_elm)
    select_list(text)
  end
  def delete()
    delete_elm = table_Element("Delete",@rowNo)
    mouse_over_and_click(delete_elm)
  end
  def add_new_line()
    newLine_elm = find_by_id("addNewLineItemButton")
    mouse_over_and_click(newLine_elm)
  end
end
# Invoice Table Class -- End

# Login Class -- Start
class LoginPage
  def login(userID,password)
    $driver.find_element(name: 'userName').send_keys userID
    $driver.find_element(name: 'password').send_keys password
    $driver.find_element(id: 'submitButton').click
  end
end
# Login Class -- End

#========= End of function and classes library =========#

#================= Start of Script =================#
$driver = Selenium::WebDriver.for :chrome
wait = Selenium::WebDriver::Wait.new(:timeout => 10) # seconds

$driver.get "https://login.xero.com/"
wait.until { $driver.execute_script("return document.readyState;") == "complete" }
$driver.find_element(css: "h2[class='x-boxed noBorder']").text.should == "Welcome to Xero"

xeroUser = LoginPage.new # Make use of login class
xeroUser.login("rupesh.more@hotmail.com","XeroDem0") # your userid and password will go here
wait.until { $driver.execute_script("return document.readyState;") == "complete" }
$driver.find_element(css: 'a#Dashboard').text.should == "Dashboard"
$driver.find_element(css: 'span#title').text.should == "ABC Inc"

# Click on Accounts and Sales Sub Menu. Verify the Sales page
$driver.find_element(id: 'Accounts').click
$driver.find_element(css: "a[data-type='menu-focus'][href*='Receivable']").click
wait.until { $driver.execute_script("return document.readyState;") == "complete" }
$driver.find_element(css: 'header#page_title').text.should == "Sales"

# Click on Repeating link. Verify the repeating invoice search page displayed
$driver.find_element(css: "a[href='/AccountsReceivable/SearchRepeating.aspx']").click
wait.until { $driver.execute_script("return document.readyState;") == "complete" }
$driver.find_element(css: 'span#title').text.should == "Invoices"

# Click on create New Repeating Invoice button. Verify the new repeating invoice page displayed
$driver.find_element(css: "a[href='/RepeatTransactions/Edit.aspx?type=AR']").click
wait.until { $driver.execute_script("return document.readyState;") == "complete" }
$driver.find_element(css: 'span.breadcrumb').text.include? "New Repeating Invoice"

# Enter the data in the fields
$driver.find_element(id: 'TimeUnit_toggle').click
$driver.find_element(id: 'StartDate_container').click
$driver.find_element(id: 'StartDate').send_keys "31 July 2014"
$driver.find_element(id: 'DueDateDay').send_keys "1"
$driver.find_element(id: 'DueDateType_toggle').click
$driver.find_element(id: 'DueDateType_toggle').click
$driver.find_element(id: 'saveAsAutoApproved').click
$driver.find_element(css: "input[type='text'][id^='PaidToName_']").send_keys "Automation Task"
$driver.find_element(css: "input[type='text'][id^='Reference_']").send_keys "Workflow"

# Add data to the first row of Invoice Table
firstRow = InvoiceTable.new(1)
firstRow.description("Automated Testing Book")
firstRow.qty("2")
firstRow.unit_price("5")
firstRow.account("429 - General Expenses")

# Add data to the second row of Invoice Table
secondRow = InvoiceTable.new(2)
secondRow.description("Ruby")
secondRow.qty("5")
secondRow.unit_price("10")
secondRow.account("461 - Printing & Stationery")

# Delete the empty rows.
thirdRow = InvoiceTable.new(3)
thirdRow.delete
thirdRow.delete
thirdRow.delete

# Add new blank row by clicking "Add New Line Button"
thirdRow.add_new_line
# Add existing inventory item to the new third row
thirdRow.item("PostIT")

# Cilck on Save button
$driver.find_element(css: "div[class='buttons footer no-margin-bottom'] button>Span").click

# Wait for page to load and verif newly repeating invoice created
wait.until { $driver.find_element(id: 'notify01').displayed? }
$driver.find_element(css: "div#notify01 p").text.include? "Repeating Template Saved."

# Uncomment following line to close the browser after execution
#$driver.quit
#================= End of Script =================#
