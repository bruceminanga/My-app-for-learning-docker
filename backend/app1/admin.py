from django.contrib import admin
from .models import Item

@admin.register(Item)
class ItemAdmin(admin.ModelAdmin):
    # The columns you want to see in the admin list view
    list_display = ('id', 'name', 'description') 
    
    # Adds a search bar to search by name
    search_fields = ('name',)