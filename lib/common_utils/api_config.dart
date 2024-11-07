library APIConstants;

const String SUCCESS_MESSAGE = " You will be contacted by us very soon.";

const baseUrl = "http://182.18.157.215/3FAkshaya/API/api/"; // Test
//var baseUrl ="http://182.18.157.215/SaloonApp_Live/API/";//live

var getBanners = "GetBanner?Id=null";
var getbanners = "Banner/GetActiveBannerByStateCode/";
var getServices = "StateService/GetServicesByStateCode/";
var getlearning = "Encyclopedia/GetActiveEncyclopediaCategoryDetails";
var Farmer_otp = "Farmer/";
var Farmer_ID_CHECK = "farmer/SendOTP/";
var getcollection = "Collection";
var getCollectionInfoById = "Collection/CollectionInfoById/";
var getActivePlotsByFarmerCode = "Farmer/GetActivePlotsByFarmerCode/";
// http://182.18.157.215/3FAkshaya/API/api/Farmer/GetActivePlotsByFarmerCode/APWGBDAB00010005
//MARK: Banners
var getActiveBannerByStateCode = "Banner/GetActiveBannerByStateCode/API";
var getbankdetails = "Farmer/GetBankDetailsByFarmerCode/";
var getvendordata = 'Payment/GetVendorLedger';
var getTranspotationdata = 'Payment/GetTranspotationChargesByFarmerCode';
var getfarmerreimbursement = 'Payment/GetTranspotationChargesByFarmerCode';
var encyclopedia = 'Encyclopedia/GetEncyclopediaDetails/'; // 1/AP/true
var getCropMaintenanceHistoryDetailsByPlotCode =
    'GetCropMaintenanceHistoryDetailsByPlotCode';
var GetCategoriesByParentCategory =
    "Categories/GetCategoriesByParentCategory/1";
var GetPaymentsTypeByFarmerCode = "Farmer/GetPaymentsTypeByFarmerCode/";
const getUnPaidCollections = 'Farmer/GetUnPayedCollectionsByFarmerCode/';
const raiseCollectionRequest = 'RequestHeader/CanRaiseRequest/';
const quickPayRequest = 'QuickPayRequest/GetQuickpayDetailsByFarmerCode';
const addQuickpayRequest = 'QuickPayRequest/AddQuickpayRequest';
const loanRequest = 'RequestHeader/AddRequestHeader';
const Getproductdata = 'Products/GetProductsByGodown';
const GetActivegodowns = 'Godown/GetActiveGodowns/';
const productsubRequest = 'FertilizerRequest';
const typeOfIssues = 'TypeCdDmt/';
const visitRequest = 'RequestHeader/AddVisitRequest';
const getVisitRequestDetails = 'RequestHeader/GetVisitRequestDetails';
const getLoanRequestDetails = 'RequestHeader/GetLoanRequestDetails';
const getVisitRequestCompleteDetails =
    'RequestHeader/GetVisitRequestRepository/';
const getFertilizerDetails = 'GetFertilizerDetails';
const getFertilizerProductDetails = 'GetProductDetailsByRequestCode/';
const getEquipmentProductDetails = 'FertilizerRequest/GetPoleRequestDetails';
const getEdibleOilsProductDetails =
    'FertilizerRequest/GetEdibleOilsRequestDetails';
const getQuickpayProductDetails = 'QuickPayRequest/GetQuickpayRequestDetails';
const getLoanProductDetails = 'RequestHeader/GetLoanRequestDetails';
const getVisitProductDetails = 'RequestHeader/GetVisitRequestDetails';
const getLabProductDetails = 'FertilizerRequest/GetChemicalRequestDetails';
const getLabourProductDetails = 'GetLabourRequestDetails';
const collectionInfoById = 'Collection/CollectionInfoById/';
const get3FInfo = 'Farmer/Get3FInfo/';
const getQuickpayDocument = 'QuickPayRequest/GetQuickpayDocument/';
const passbookFileLocation = '/sdcard/Download/3FAkshaya/ledger';

// APWGBDAB00010005
var getLabourServicetype = "Farmer/GetServicesByPlotCode/";
var getLabourDuration = "TypeCdDmt/7";
var getLabourServiceCost = 'LabourServiceCost/GetLabourServiceCostCalculation';
const getlabourservicecost = 'LabourServiceCost/GetLabourServiceCost/null';
var addlabourequest = 'LabourRequest/AddLabourRequestHeader';
