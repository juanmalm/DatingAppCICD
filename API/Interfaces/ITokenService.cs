using API.Entities;

namespace API.Interfaces
{
    public interface ITokenService
    {
        Task<string> CreateToken01(AppUser user);
        Task<string> CreateToken02(AppUser user);
    }
}