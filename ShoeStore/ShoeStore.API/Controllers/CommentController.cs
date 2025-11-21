using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.Dtos.Comment;
using ShoeStore.Application.Interfaces.Services;

namespace ShoeStore.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CommentsController : ControllerBase
    {
        private readonly ICommentService _commentService;

        public CommentsController(ICommentService commentService)
        {
            _commentService = commentService;
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<ActionResult<IEnumerable<CommentDto>>> GetAll()
        {
            var comments = await _commentService.GetAllAsync();
            return Ok(comments);
        }

        [HttpGet("{id:long}")]
        [AllowAnonymous]
        public async Task<ActionResult<CommentDto>> GetById(long id)
        {
            var comment = await _commentService.GetByIdAsync(id);
            return comment == null ? NotFound() : Ok(comment);
        }

        [HttpGet("product/{productId:int}")]
        [AllowAnonymous]
        public async Task<ActionResult<IEnumerable<CommentDto>>> GetByProductId(int productId)
        {
            var comments = await _commentService.GetByProductIdAsync(productId);
            return Ok(comments);
        }

        [HttpPost]
        [Authorize(Roles = "Customer,Super Admin,Admin,Staff")]
        public async Task<ActionResult<CommentDto>> Create([FromBody] CreateCommentDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var created = await _commentService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [HttpPut("{id:long}")]
        [Authorize(Roles = "Super Admin,Admin,Staff")]
        public async Task<ActionResult<CommentDto>> Update(long id, [FromBody] UpdateCommentDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var updated = await _commentService.UpdateAsync(id, dto);
            return updated == null ? NotFound() : Ok(updated);
        }

        [HttpDelete("{id:long}")]
        [Authorize(Roles = "Super Admin,Admin,Staff")]
        public async Task<ActionResult> Delete(long id)
        {
            var deleted = await _commentService.DeleteAsync(id);
            return deleted ? NoContent() : NotFound();
        }
    }
}
