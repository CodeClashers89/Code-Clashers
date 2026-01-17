"""
AI-powered utility functions for complaint analysis using OpenAI GPT-4o-mini
"""
from openai import OpenAI
from django.conf import settings
import logging

logger = logging.getLogger(__name__)


def analyze_complaint_priority(title: str, description: str, category: str = "") -> str:
    """
    Analyze a complaint and determine its priority level using OpenAI GPT-4o-mini.
    
    Args:
        title: The complaint title
        description: The detailed complaint description
        category: The complaint category (optional)
    
    Returns:
        Priority level as string: "low", "medium", or "high"
        Defaults to "medium" if API call fails
    """
    try:
        # Check if OpenAI API key is configured
        api_key = getattr(settings, 'OPENAI_API_KEY', None)
        if not api_key:
            logger.warning("OpenAI API key not configured. Defaulting to medium priority.")
            return "medium"
        
        # Initialize OpenAI client
        client = OpenAI(api_key=api_key)
        
        # Construct the analysis prompt
        category_text = f"\nCategory: {category}" if category else ""
        
        prompt = f"""Analyze this urban complaint and assign a priority level based on:
- Public safety impact (immediate danger to people)
- Urgency of resolution needed (time-sensitive issues)
- Potential for escalation (could get worse quickly)
- Number of people affected (community-wide vs individual)
- Infrastructure criticality (essential services)

Complaint Title: {title}
Description: {description}{category_text}

Respond with ONLY one word from these options: low, medium, high

Priority Guidelines:
- HIGH: Immediate safety hazards, major infrastructure failures, widespread impact, emergency situations
- MEDIUM: Significant issues requiring attention, moderate impact, non-emergency but important
- LOW: Minor inconveniences, cosmetic issues, individual concerns, non-urgent matters

Your response (one word only):"""
        
        # Call OpenAI API
        model = getattr(settings, 'OPENAI_MODEL', 'gpt-4o-mini')
        response = client.chat.completions.create(
            model=model,
            messages=[
                {
                    "role": "system",
                    "content": "You are an expert urban planning analyst specializing in prioritizing municipal complaints. You provide concise, accurate priority assessments."
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            temperature=0.3,  # Lower temperature for more consistent results
            max_tokens=10,  # We only need one word
        )
        
        # Extract and validate the priority
        priority = response.choices[0].message.content.strip().lower()
        
        # Validate the response
        valid_priorities = ['low', 'medium', 'high']
        if priority not in valid_priorities:
            logger.warning(f"Invalid priority returned by AI: {priority}. Defaulting to medium.")
            return "medium"
        
        logger.info(f"AI assigned priority '{priority}' to complaint: {title[:50]}...")
        return priority
        
    except Exception as e:
        logger.error(f"Error analyzing complaint priority: {str(e)}")
        # Default to medium priority on any error
        return "medium"


def batch_analyze_priorities(complaints: list) -> dict:
    """
    Analyze multiple complaints in batch (for future optimization).
    
    Args:
        complaints: List of dicts with 'id', 'title', 'description', 'category'
    
    Returns:
        Dictionary mapping complaint IDs to priority levels
    """
    results = {}
    for complaint in complaints:
        priority = analyze_complaint_priority(
            title=complaint.get('title', ''),
            description=complaint.get('description', ''),
            category=complaint.get('category', '')
        )
        results[complaint.get('id')] = priority
    
    return results
