from django.http import HttpResponse

def test(request):
    html = "<html><body>Pieter is a poop</body></html>" 
    return HttpResponse(html)
