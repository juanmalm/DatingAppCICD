using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Firefox;
using OpenQA.Selenium.IE;
using OpenQA.Selenium;

namespace API.AcceptanceTests
{
    [TestClass]
    public class RegisterTests
    {
        public TestContext? TestContext { get; set; }

        private IWebDriver? driver;
        private string? appURL;

        public RegisterTests()
        {
        }

        [TestMethod]
        [TestCategory("Chrome")]
        public void RegisterButtonOpensSignUpForm()
        {
            driver?.Navigate().GoToUrl(appURL + "/");
            driver?.FindElement(By.XPath("//button[text()=\"Register\"]")).Click();
            Assert.IsTrue(driver?.FindElement(By.XPath("//h2[text()=\"Sign up\"]")) != null, "Verified 'Sign up' content");
        }

        [TestInitialize()]
        public void SetupTest()
        {
            var appIp = Environment.GetEnvironmentVariable("APP_IP") ?? "127.0.0.1";
            appURL = $"http://{appIp}:8080/";

            var options = new ChromeOptions();
            options.AddArgument("no-sandbox");
            driver = new ChromeDriver(options);
        }

        [TestCleanup()]
        public void MyTestCleanup()
        {
            driver?.Quit();
        }
    }
}