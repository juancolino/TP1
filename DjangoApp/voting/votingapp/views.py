from django.shortcuts import render
from django.http import HttpResponse

from votingapp.models import Scoreboard

# Create your views here.

def index(request):
    sb = Scoreboard.objects.get(pk=1)
    return render(request, 'votingapp/index.html', {'scoreBoard': sb})
    
def getCounters(request):
    sb = Scoreboard.objects.get(pk=1)
    return HttpResponse(str(sb.currentVotes) + " " + str(sb.flagCount))

def addVote(request):
    sb = Scoreboard.objects.get(pk=1)
    sb.currentVotes = sb.currentVotes + 1
    sb.save()
    return render(request, 'votingapp/index.html', {'scoreBoard': sb})
    
def activateFlag(request):
    sb = Scoreboard.objects.get(pk=1)
    sb.flagCount = sb.flagCount + 1
    sb.save()
    return render(request, 'votingapp/index.html', {'scoreBoard': sb})
    
def resetCounters(request):
    sb = Scoreboard.objects.get(pk=1)
    sb.currentVotes = 0
    sb.flagCount = 0
    sb.save()
    return render(request, 'votingapp/index.html', {'scoreBoard': sb})