*** Settings ***
Documentation       Template robot main suite.
Library    RPA.Browser.Selenium
Library    RPA.HTTP
Library    RPA.Excel.Files
Library    RPA.Tables
Library    RPA.Desktop
Library    RPA.PDF
Library    RPA.FileSystem
Library    RPA.Archive

*** Keywords ***
Open webpage
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Accept PopUp
    Wait Until Element Is Visible    xpath:/html/body/div/div/div[2]/div/div/div/div/div/button[1]    10s
    Click Button    xpath:/html/body/div/div/div[2]/div/div/div/div/div/button[1]

Download csv file
    Download    https://robotsparebinindustries.com/orders.csv    ${OUTPUT_DIR}${/}orders.csv

Fill webpage with csv data
    ${orders}=    Read table from CSV    orders.csv    header=${True}
    FOR    ${order}    IN    @{orders}
        Input data    ${order}
        Preview order and Download robot image    ${order}[Order number]
        Order robot and get receipt    ${order}[Order number]     ${OUTPUT_DIR}${/}${order}[Order number].png
        Complete order
        Accept PopUp
    END

Preview order and Download robot image
    [Arguments]    ${order_number}
    Click Button    preview
    Wait Until Element Is Visible    robot-preview-image
    Screenshot    robot-preview-image    ${OUTPUT_DIR}${/}${order_number}.png

Input data
    [Arguments]    ${data}
    Select From List By Value    head    ${data}[Head]
    Select Radio Button    body    id-body-${data}[Body]
    Input Text   xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${data}[Legs]
    Input Text    address    ${data}[Address]

Order robot and get receipt
    [Arguments]    ${order_number}    ${RobotImagePath}
    Click Button    order
    Sleep    2s
    ${IsAvailable}=     Is Element Visible    receipt
    WHILE    ${IsAvailable} == ${False}
        Click Button    order
        Sleep    2s
        ${IsAvailable}=     Is Element Visible    receipt
    END
    Get receipt as HTML and merge robot image    ${order_number}    ${RobotImagePath}
    Remove robot image    ${RobotImagePath}

Get receipt as HTML and merge robot image
    [Arguments]    ${pdfNumber}    ${robotPath}
    Wait Until Element Is Visible    receipt
    ${outerHTMLReceipt}=    Get Element Attribute    receipt    outerHTML
    Create Directory    ${OUTPUT_DIR}${/}receipts    parents=${True}    exist_ok=${True}
    Html To Pdf    ${outerHTMLReceipt}    ${OUTPUT_DIR}${/}receipts${/}Receipt-${pdfNumber}.pdf
    ${files}=    Create List    ${OUTPUT_DIR}${/}receipts${/}Receipt-${pdfNumber}.pdf    ${robotPath}
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}receipts${/}Receipt-${pdfNumber}.pdf
    

Remove robot image
    [Arguments]    ${RobotImagePath}
    Remove File    ${RobotImagePath}    missing_ok=${True}

Complete order
    Click Button    order-another

Create zip with receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    receipts.zip

*** Tasks ***
    Open webpage
    Accept PopUp
    Download csv file
    Fill webpage with csv data
    Create zip with receipts

