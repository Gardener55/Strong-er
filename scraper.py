import requests
from bs4 import BeautifulSoup
import json

def scrape_exercise_page(url):
    try:
        page = requests.get(url)
        soup = BeautifulSoup(page.content, 'html.parser')

        name = soup.find('h1').text.strip()

        # The details are not in a div with class 'exercise-details' anymore.
        # They are in the div with class 'col-md-4'
        details_container = soup.find('div', class_='col-md-4')

        target_body_part_text = details_container.find('p', text='Target Body Part:').find_next_sibling(text=True).strip()

        equipment_text = details_container.find('p', text='Equipment:').find_next_sibling(text=True).strip()

        difficulty_text = details_container.find('p', text='Difficulty:').find_next_sibling('img')['alt'].replace(' exercise meter', '').strip()

        instructions = []
        # Instructions are now in a div with class 'col-md-8'
        instructions_container = soup.find('div', class_='col-md-8')
        for step in instructions_container.find_all('h3'):
            if "Step" in step.text:
                instruction_text = step.find_next_sibling('p').text.strip()
                instructions.append(instruction_text)


        exercise_data = {
            "name": name,
            "target_body_part": target_body_part_text,
            "equipment": equipment_text,
            "difficulty": difficulty_text,
            "instructions": instructions
        }

        return exercise_data
    except Exception as e:
        print(f"Error scraping {url}: {e}")
        return None

def scrape_equipment_category(category_url):
    exercises = []
    try:
        page = requests.get(category_url)
        soup = BeautifulSoup(page.content, 'html.parser')

        exercise_links = [a['href'] for a in soup.select('h5.card-title a')]

        for link in exercise_links:
            # The links are relative, so I need to join them with the base URL
            exercise_url = f"https://www.acefitness.org{link}"
            exercise_data = scrape_exercise_page(exercise_url)
            if exercise_data:
                exercises.append(exercise_data)

    except Exception as e:
        print(f"Error scraping category {category_url}: {e}")

    return exercises

if __name__ == '__main__':
    EQUIPMENT_URLS = {
        "no_equipment": "https://www.acefitness.org/resources/everyone/exercise-library/equipment/no-equipment/",
        "dumbbells": "https://www.acefitness.org/resources/everyone/exercise-library/equipment/dumbbells/",
        "barbell": "https://www.acefitness.org/resources/everyone/exercise-library/equipment/barbell/",
        "bench": "https://www.acefitness.org/resources/everyone/exercise-library/equipment/bench/",
        "bosu_trainer": "https://www.acefitness.org/resources/everyone/exercise-library/equipment/bosu-trainer/",
        "stability_ball": "https://www.acefitness.org/resources/everyone/exercise-library/equipment/stability-ball/",
        "medicine_ball": "https://www.acefitness.org/resources/everyone/exercise-library/equipment/medicine-ball/",
    }

    all_exercises = {}
    for equipment, url in EQUIPMENT_URLS.items():
        print(f"Scraping {equipment} exercises...")
        all_exercises[equipment] = scrape_equipment_category(url)

    with open('exercises.json', 'w') as f:
        json.dump(all_exercises, f, indent=4)

    print("Scraping complete. Exercises saved to exercises.json")
