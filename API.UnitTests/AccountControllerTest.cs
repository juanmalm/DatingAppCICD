using API.Controllers;
using API.DTOs;
using API.Entities;
using API.Interfaces;
using AutoMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using MockQueryable.Moq;

namespace API.UnitTests
{
    public class AccountControllerTest
    {
        private readonly AccountController _accountController;

        private readonly Mock<UserManager<AppUser>> _userManager;
        private readonly Mock<ITokenService> _tokenService = new();
        private readonly Mock<IMapper> _mapper = new();

        public AccountControllerTest() 
        {
            _userManager = MockUserManager<AppUser>(new List<AppUser>());

            _accountController = new AccountController(_userManager.Object, _tokenService.Object, _mapper.Object);
        }

        [Fact]
        public async Task Login_UnauthorizedObjectResult()
        {
            var loginDto = new LoginDto { Username = "user", Password = "password" };

            var result = await _accountController.Login(loginDto);

            result.Result.Should().BeOfType<UnauthorizedObjectResult>();
        }

        public static Mock<UserManager<TUser>> MockUserManager<TUser>(List<TUser> ls) where TUser : class
        {
            var mock = ls.AsQueryable().BuildMock();
            var store = new Mock<IUserStore<TUser>>();
            var mgr = new Mock<UserManager<TUser>>(store.Object, null, null, null, null, null, null, null, null);
            mgr.Setup(x => x.Users).Returns(mock);
            mgr.Object.UserValidators.Add(new UserValidator<TUser>());
            mgr.Object.PasswordValidators.Add(new PasswordValidator<TUser>());

            mgr.Setup(x => x.DeleteAsync(It.IsAny<TUser>())).ReturnsAsync(IdentityResult.Success);
            mgr.Setup(x => x.CreateAsync(It.IsAny<TUser>(), It.IsAny<string>())).ReturnsAsync(IdentityResult.Success).Callback<TUser, string>((x, y) => ls.Add(x));
            mgr.Setup(x => x.UpdateAsync(It.IsAny<TUser>())).ReturnsAsync(IdentityResult.Success);

            return mgr;
        }
    }
}