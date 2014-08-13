from django.db import models

# Create your models here.

class Scoreboard(models.Model):
    currentVotes = models.IntegerField(default=0)
    flagCount = models.IntegerField(default=0)