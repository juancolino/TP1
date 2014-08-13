from django.conf.urls import patterns, url

from votingapp import views

urlpatterns = patterns('',
    url(r'^$', views.index, name='index'),
    url(r'^getCounters', views.getCounters, name='getCounters'),
    url(r'^addVote', views.addVote, name='addvote'),
    url(r'^activateFlag', views.activateFlag, name='activateFlag'),
    url(r'^resetCounters', views.resetCounters, name='resetCounters'),
)