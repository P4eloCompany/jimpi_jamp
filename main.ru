import pygame
import random
import sys

# Инициализация Pygame
pygame.init()

# Константы экрана (горизонтальный режим)
WIDTH, HEIGHT = 800, 400
FPS = 60

# Цвета
BG_COLOR = (20, 25, 40)
GROUND_COLOR = (50, 50, 70)
PLAYER_COLOR = (50, 150, 255)
OBSTACLE_COLOR = (255, 70, 70)
WHITE = (255, 255, 255)

# Настройки физики
GRAVITY = 1.2
JUMP_STRENGTH = -16
PLAYER_SIZE = 40
GROUND_Y = HEIGHT - 50

class Player:
    def __init__(self):
        self.rect = pygame.Rect(100, GROUND_Y - PLAYER_SIZE, PLAYER_SIZE, PLAYER_SIZE)
        self.vel_y = 0
        self.is_jumping = False

    def update(self):
        self.vel_y += GRAVITY
        self.rect.y += self.vel_y
        if self.rect.bottom >= GROUND_Y:
            self.rect.bottom = GROUND_Y
            self.vel_y = 0
            self.is_jumping = False

    def jump(self):
        if not self.is_jumping:
            self.vel_y = JUMP_STRENGTH
            self.is_jumping = True

    def draw(self, surface):
        pygame.draw.rect(surface, PLAYER_COLOR, self.rect)
        pygame.draw.rect(surface, WHITE, self.rect, 2)

class Obstacle:
    def __init__(self):
        width = random.randint(30, 50)
        height = random.randint(50, 100)
        self.rect = pygame.Rect(WIDTH, GROUND_Y - height, width, height)

    def update(self, speed):
        self.rect.x -= speed

    def draw(self, surface):
        pygame.draw.rect(surface, OBSTACLE_COLOR, self.rect)
        pygame.draw.rect(surface, WHITE, self.rect, 2)

class Game:
    def __init__(self):
        self.screen = pygame.display.set_mode((WIDTH, HEIGHT))
        pygame.display.set_caption("Jimpi Jamp - Python")
        self.clock = pygame.time.Clock()
        self.font_large = pygame.font.SysFont("Arial", 48, bold=True)
        self.font_small = pygame.font.SysFont("Arial", 24)
        
        self.state = "MENU" 
        self.reset_game()

    def reset_game(self):
        self.player = Player()
        self.obstacles = []
        self.score = 0
        self.spawn_timer = 0
        self.spawn_time = 90 # Кадров между препятствиями
        self.obstacle_speed = 8

    def handle_action(self):
        """Вызывается при клике, нажатии пробела или тапе по экрану"""
        if self.state == "MENU":
            self.state = "PLAYING"
        elif self.state == "PLAYING":
            self.player.jump()
        elif self.state == "GAME_OVER":
            self.reset_game()
            self.state = "PLAYING"

    def handle_events(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
            
            # Управление для ПК (Мышь, Пробел, Вверх)
            if event.type == pygame.MOUSEBUTTONDOWN or \
               (event.type == pygame.KEYDOWN and event.key in [pygame.K_SPACE, pygame.K_UP]):
                self.handle_action()
            
            # Управление для Телефона (Касание экрана)
            if event.type == pygame.FINGERDOWN:
                self.handle_action()

    def update(self):
        if self.state == "PLAYING":
            self.player.update()
            self.score += 0.1

            # Спавн и ускорение
            self.spawn_timer += 1
            if self.spawn_timer >= self.spawn_time:
                self.obstacles.append(Obstacle())
                self.spawn_timer = 0
                if self.spawn_time > 50:
                    self.spawn_time -= 1
                    self.obstacle_speed += 0.05

            for obs in self.obstacles[:]:
                obs.update(self.obstacle_speed)
                if obs.rect.right < 0:
                    self.obstacles.remove(obs)
                if self.player.rect.colliderect(obs.rect):
                    self.state = "GAME_OVER"

    def draw(self):
        self.screen.fill(BG_COLOR)
        pygame.draw.rect(self.screen, GROUND_COLOR, (0, GROUND_Y, WIDTH, HEIGHT - GROUND_Y))
        pygame.draw.line(self.screen, WHITE, (0, GROUND_Y), (WIDTH, GROUND_Y), 2)

        if self.state == "MENU":
            title = self.font_large.render("JIMPI JAMP", True, WHITE)
            hint = self.font_small.render("Нажми, чтобы играть", True, WHITE)
            self.screen.blit(title, (WIDTH//2 - title.get_width()//2, HEIGHT//2 - 60))
            self.screen.blit(hint, (WIDTH//2 - hint.get_width()//2, HEIGHT//2 + 10))

        elif self.state == "PLAYING":
            self.player.draw(self.screen)
            for obs in self.obstacles:
                obs.draw(self.screen)
            score_text = self.font_small.render(f"Очки: {int(self.score)}", True, WHITE)
            self.screen.blit(score_text, (20, 20))

        elif self.state == "GAME_OVER":
            self.player.draw(self.screen)
            for obs in self.obstacles:
                obs.draw(self.screen)
            over_text = self.font_large.render("ИГРА ОКОНЧЕНА", True, OBSTACLE_COLOR)
            score_text = self.font_small.render(f"Твой счёт: {int(self.score)}", True, WHITE)
            hint = self.font_small.render("Нажми, чтобы попробовать снова", True, WHITE)
            self.screen.blit(over_text, (WIDTH//2 - over_text.get_width()//2, HEIGHT//2 - 80))
            self.screen.blit(score_text, (WIDTH//2 - score_text.get_width()//2, HEIGHT//2 - 10))
            self.screen.blit(hint, (WIDTH//2 - hint.get_width()//2, HEIGHT//2 + 40))

        pygame.display.flip()

    def run(self):
        while True:
            self.handle_events()
            self.update()
            self.draw()
            self.clock.tick(FPS)

if __name__ == "__main__":
    game = Game()
    game.run()