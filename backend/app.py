import re
from flask import Flask, request, jsonify
from flask_cors import CORS  # Import the CORS package
from ibm_watsonx_ai.foundation_models import Model
import os
from transformers import pipeline
from collections import Counter

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes


poetry_classifier = pipeline('text-classification', model='Ammar-alhaj-ali/arabic-MARBERT-poetry-classification')

sentiment_analyzer = pipeline('sentiment-analysis', model='CAMeL-Lab/bert-base-arabic-camelbert-msa-sentiment')

# Function to get credentials
def get_credentials():
    return {
        "url": "https://eu-de.ml.cloud.ibm.com",
        "apikey": "qV28RC9lM7YrsUcSoJBORmBIK4U9fGapPuOGRG_FrkRW"
    }

# IBM Watson Model Configuration
model_id = "sdaia/allam-1-13b-instruct"
parameters = {
    "decoding_method": "greedy",
    "max_new_tokens": 900,
    "repetition_penalty": 1.2
}



project_id = "49c4e06a-087c-4718-8797-42bbb8d89c39"
space_id = os.getenv("SPACE_ID")

model = Model(
    model_id=model_id,
    params=parameters,
    credentials=get_credentials(),
    project_id=project_id,
    space_id=space_id
)



@app.route('/analyze_rhyme', methods=['POST'])
def analyze_rhyme():
    data = request.json
    poem = data.get('poem')

    if not poem:
        return jsonify({"error": "No poem provided"}), 400

    try:
        rhyme_options = [
        "قافية الألف (ا)", "قافية الألف الممدودة (آ)", "قافية الألف الهمزة (أ)", "قافية الياء همزة (ئ)", 
        "قافية الواو همزة (ؤ)", "قافية الباء (ب)", "قافية التاء (ت)", "قافية الثاء (ث)", 
        "قافية الجيم (ج)", "قافية الحاء (ح)", "قافية الخاء (خ)", "قافية الدال (د)", 
        "قافية الذال (ذ)", "قافية الراء (ر)", "قافية الزاي (ز)", "قافية السين (س)", 
        "قافية الشين (ش)", "قافية الصاد (ص)", "قافية الضاد (ض)", "قافية الطاء (ط)", 
        "قافية الظاء (ظ)", "قافية العين (ع)", "قافية الغين (غ)", "قافية الفاء (ف)", 
        "قافية القاف (ق)", "قافية الكاف (ك)", "قافية اللام (ل)", "قافية الميم (م)", 
        "قافية النون (ن)", "قافية الهاء (هـ)", "قافية الواو (و)", "قافية الياء (ي)"
        ]

        prompt = f"""
        <s>[INST] <<SYS>>
        أنت ناقد أدبي مختص بتحليل الشعر العربي، ومهمتك تحديد القافية الأنسب للقصيدة المقدمة من القائمة المحددة. 
        أجب فقط بالقافية الملائمة دون أي تفسير إضافي.
        <</SYS>> [/INST]

        <s>[INST]
        ### تحليل القافية:
        **النص الشعري:**
        {poem}

        **خيارات القافية المتاحة:**
        {', '.join(rhyme_options)}

        **حدد القافية الصحيحة فقط:**
        [/INST]
        """

        rhyme_analysis = model.generate_text(prompt=prompt, guardrails=False).strip()
        return jsonify({"rhyme": rhyme_analysis}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/classify_theme', methods=['POST'])  # Changed route name
def classify_theme():
    data = request.json
    poem = data.get('poem')
    
    if not poem:
        return jsonify({"error": "No poem provided"}), 400

    try:
        themes = [
            'قصائد المعلقات',
            'قصائد الأناشيد',
            'قصائد اعتذار',
            'قصائد ابتهال',
            'قصائد دينية',
            'قصائد حكمة',
            'قصائد حزينة',
            'قصائد جود وكرم',
            'قصائد رومنسية',
            'قصائد رحمة',
            'قصائد رثاء',
            'قصائد دم',
            'قصائد عامة',
            'قصائد صبر',
            'قصائد شوق',
            'قصائد سياسية',
            'قصائد غزل',
            'قصائد عدل',
            'قصائد عتاب',
            'قصائد فرَاق',
            'قصائد مدح',
            'قصائد نصيحة',
            'قصائد قصيرة',
            'قصائد وطنية'
        ]
        
        prompt = f"""
        <s>[INST] <<SYS>>
        أنتَ مُختصٌّ في تحليلِ الشّعرِ العربيِّ، وقادرٌ على تحديدِ موضوعِهِ بدقَّةٍ، بالاعتمادِ على تحليلِ عناصِرِهِ المختلفةِ. 
        ستتلقّى قصيدةً، ومطلوبٌ منكَ تحديدُ الفئةِ الموضوعيَّةِ الأكثرِ دقَّةً لها من قائمةٍ مُحدَّدةٍ. 
        التزمْ بالإرشاداتِ التاليةِ عندَ تحليلِ القصيدةِ:
        * **قراءةٌ متأنّيةٌ:** ابدأْ بقراءةِ القصيدةِ بتأنٍّ وتركيزٍ.
        * **فهمُ العناصرِ:** حلّلِ عناصرَ القصيدةِ، مثلَ: اللّغةِ، والصّورِ البيانيَّةِ، والأفكارِ الرّئيسةِ.
        * **تحديدُ الموضوعِ:** حدّدِ الموضوعَ المركزيَّ الّذي تدورُ حولهُ القصيدةُ.
        * **مطابقةُ الفئاتِ:** قارنِ الموضوعَ الّذي حدَّدتَهُ معَ الفئاتِ المُتاحةِ، واخترِ الفئةَ الأكثرَ دقّةً وملاءمةً.
        <</SYS>> 
        [/INST]
        <s>[INST]
        ## أمثلةٌ على التّصنيف:

        **مثال ١:**
        **القصيدة:**
        لَيتَ شِعري هَل غادَرَ الشُعَراءُ مِن مُتَـرَدَّمِ *** أَم هَل عَرَفتِ الدارَ بَعدَ تَوَهُّمِ
        **الفئات المتاحة:** قصيدة المعلقات، قصيدة غزل، قصيدة سياسية
        **الجواب:** قصيدة المعلقات

        **مثال ٢:**
        **القصيدة:**
        لا تَسلْنِي لِمَ أَسْهَرْتُ عَينَيَّ بالدُّموعِ *** إنَّما العِشْقُ يا صَديقي شَجاعَتي وَخَنوعي
        **الفئات المتاحة:** قصيدة دينية، قصيدة غزل، قصيدة رثاء
        **الجواب:** قصيدة غزل

        **مثال ٣:**
        **القصيدة:**
        إِذَا مَا بَلَغْتَ بِهِ الدُّنْيَا مَنَازِلَهُ *** فَكُنْ كَمَنْ زَهَدَتْ فِي الوُدِّ أَسْلَابُهُ
        **الفئات المتاحة:** قصيدة حكمة، قصيدة سياسية، قصيدة اعتذار
        **الجواب:** قصيدة حكمة

        **مثال ٤:**
        **القصيدة:**
        أَرَاكَ العَصَا النَّاعِمَةَ الَّتِي *** تُؤَدِّبُ قَلْبِي إذا ما غَوَى
        **الفئات المتاحة:** قصيدة نصيحة، قصيدة عتاب، قصيدة مدح
        **الجواب:** قصيدة عتاب

        ## مهمَّةُ التّصنيفِ:

        **القصيدة:**
        {poem}

        **الفئاتُ المُتاحةُ:**
        {', '.join(themes)}

        **الجواب:**
        [اكتبِ هنا الفئةَ المُناسبةَ من القائمةِ أعلاه فقطْ، ولا تُضِفْ أيَّةَ تفاصيلَ أُخرى]
        [/INST]
        """
        
        # Generate the response (theme classification)
        classified_theme = model.generate_text(prompt=prompt, guardrails=False).strip()

        return jsonify({"theme": classified_theme}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500



@app.route('/analyze_sentiment', methods=['POST'])
def analyze_sentiment():
    data = request.json
    poem = data.get('poem')

    if not poem:
        return jsonify({"error": "No poem provided"}), 400

    try:
        # 1. Split into hemistiches (corrected splitting)
        hemistiches = []
        for line in poem.splitlines():
            hemistiches.extend(line.split('  ')) # Split on double spaces

        # 2. Combine hemistiches into verses (handling empty lines)
        verses = []
        i = 0
        while i < len(hemistiches):
            # Skip empty hemistiches (caused by empty lines)
            if not hemistiches[i].strip(): 
                i += 1
                continue

            if i + 1 < len(hemistiches) and hemistiches[i + 1].strip():
                # Combine if next hemistich exists and is not empty
                verses.append(hemistiches[i] + hemistiches[i + 1])
                i += 2
            else:
                # Otherwise, treat the current hemistich as a verse
                verses.append(hemistiches[i])
                i += 1

        # 3. Continue with sentiment analysis
        sentiment_counts = {'positive': 0, 'negative': 0, 'neutral': 0}
        sentiment_results = []

        for verse in verses:
            if verse.strip():
                result = sentiment_analyzer(verse)[0]
                sentiment = result['label']
                score = result['score']
                sentiment_counts[sentiment] += 1
                sentiment_results.append({"verse": verse, "sentiment": sentiment, "score": score})

        total_verses = len(verses)
        sentiment_percentages = {
            'positive': (sentiment_counts['positive'] / total_verses) * 100,
            'negative': (sentiment_counts['negative'] / total_verses) * 100,
            'neutral': (sentiment_counts['neutral'] / total_verses) * 100,
        }

        return jsonify({
            "overall_sentiment": max(sentiment_counts, key=sentiment_counts.get),
            "sentiment_percentages": sentiment_percentages,
            "verse_sentiments": sentiment_results,
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/analyze_emotional_tone', methods=['POST'])
def analyze_emotional_tone():
    data = request.json
    poem = data.get('poem')

    if not poem:
        return jsonify({"error": "No poem provided"}), 400

    try:
        prompt = f"""
        <s>[INST] <<SYS>> 
        أنت محلل أدبي خبير متخصص في الشعر العربي. 
        لديك قدرة عميقة على فهم المشاعر المتنوعة والمعقدة التي يعبر عنها الشعراء من خلال كلماتهم. 
        <</SYS>> 
        [/INST]
        <s>[INST]
        ### أمثلة على تحليل المشاعر في القصائد:

        **مثال ١:**
        **القصيدة:**
        خليليَّ مَهلاً فَالفراقُ عَصيبُ
        إِلامَ الرضا منا وَأَنتَ غَضوبُ
        خَليليَّ ما ذنبي وَعَيني بدمعِها
        تَجودُ  وَقَلبي يَعتريهِ وَجيبُ
        خَليليَّ  ما خُنتُ العهودَ فديتُكم
        وَخُنتُم وَهَل حفظي لَهنّ ذُنوب
        **التحليل:**
        القصيدة تعبّر عن ألم الفراق وخيانة الأحبة، حيث يتدرج الشاعر من الاستياء إلى الحزن العميق ثم إلى إحساس بالظلم، مؤكدًا وفاءه مقابل خيانة الآخرين.
        
        **مثال ٢:**
        **القصيدة:**
        أصمى  القلوب بسهم البث والحزن
        فما  له ولهذا المركب الخشن
        قام  الوزير فأرغى في خطابته
        وكاتف العزم بعد الضعف والوهن
        قام الوزير يبث اليأس في نفر
        عدوا خطابته نوعاً من المحن
        **التحليل:**
        القصيدة تعبر عن مشاعر الأسى وخيبة الأمل بسبب خطاب الوزير الذي بثّ اليأس. الشاعر يبدأ بتصوير أثر هذا الخطاب كـ "سهم البث والحزن" الذي يصيب القلوب بالألم. رغم محاولات الوزير لإظهار القوة والعزم، إلا أن خطابه اعتُبر قاسيًا ومُحبطًا، ما جعل الناس يرونه كمحنة تضاف إلى معاناتهم.

        **مثال ٣:**
        **القصيدة:**
        جَزَاهَا اللهُ قاتِـلتِي
        بكُـــلِّ الخيْرِ والسَّلَمِ
        يمرُّ الوقــتُ يَذبَحُنِي
        بلا رَحِـــمٍ ولا كَلِمِ
        لعلَّ اللهَ يُرْضِــــيْهَا
        فيَهْـــــدِيْهَا إلى حُلُمِ

        **التحليل:**
        القصيدة تعبر عن ألم الفراق والأمل في المصالحة. الشاعر يدعو لمن تسبب له بالألم بالخير والسلام، مما يعكس مزيجًا من الحب والمغفرة. يشعر الشاعر بأن الوقت يمضي ويزيد من معاناته بصمت قاسٍ، لكنه يتمسك بأمل أن ينال رضا محبوبته ويهديها إلى التسامح واللين، راجيًا أن يعود الوصل بينهما.
        ### مهمة التحليل:

        حلّل المشاعر في القصيدة التالية، مع التركيز على كيفية تغير هذه المشاعر أو تطورها خلال القصيدة. 
        لا تذكر المشاعر فقط، بل صف كيف تم التعبير عنها من خلال الصور الشعرية واللغة المستخدمة:
        {poem} 
        [/INST]
        """

        # Generate response using the improved prompt
        emotional_tone_analysis = model.generate_text(prompt=prompt, guardrails=False)
        return jsonify({"emotional_tone": emotional_tone_analysis}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/analyze_poem', methods=['POST'])
def analyze_poem():
    data = request.json
    poem = data.get('poem')

    if not poem:
        return jsonify({"error": "No poem provided"}), 400

    try:
        prompt = f"""
        <s>[INST] <<SYS>>
        انت ناقد أدبي متخصص في الشعر العربي، لديك معرفة واسعة بالأسلوب البلاغي، وقواعد العروض، والتاريخ الأدبي، والثقافة العربية. تحلل الشعر بدقة، مراعيًا عناصره المختلفة من لغة، وصور، وإيقاع، ومعنى.
        <</SYS>>
        <s>[INST]
        ### أمثلة على التحليل الأدبي:

        **مثال ١:**
        **القصيدة:**
        برغم التقى إن قوضت أخت أحمدٍ
        وفات  برغم المجد سفر التجلد
        وعالجها ريب المنون ولم تزل
        نوائبه العظمى تروح وتغتدي
        وباكرها صرف القضاء وكم غدا
        يجور على أهل المعالي ويعتدي 
        **التحليل:**
        1. الأسلوب البلاغي:
        القصيدة تتسم بالبلاغة، حيث يتكرر استخدام "برغم" للتأكيد على صمود الشاعر أمام التحديات. كما أن هناك جناسًا بين "تروح" و"تغتدي"، مما يضيف إيقاعًا موسيقيًا للقصيدة.

        2. الإيقاع:
        تتبع القصيدة البحر الكامل، مما يعزز التناغم والإيقاع الثابت في الأبيات، مما يعكس قوة الموضوع الذي يتناول المصاعب والمحن.

        3. المعنى العام:
        القصيدة تعبر عن فكرة أن التقى والعظمة لا تحمي الإنسان من مصير الموت، وأن كل فرد، مهما كان، سيواجه صعوبات الحياة والموت.

        4. الدلالات الثقافية:
        تعكس القصيدة الثقافة العربية التي تؤمن بأن العظمة والمجد لا يقيان من قدر الموت، ويبرز فيها التراث الأدبي الذي يتعامل مع الفناء والمصير المشترك.

        الخلاصة:
        القصيدة تسلط الضوء على صمود الإنسان أمام قضاء المنون، مؤكدة أن الكبرياء والمجد لا يغيران من مصير الفناء.

        **مثال ٢:**
        **القصيدة:**
        عَن القَلب لا تَسأل فَقَد ذابَ وَاِكتَوى
        وَلَم يَبقَ فيهِ غَيرُ منزلةِ الهَوى
        هَوَيتُكمُ وَالصدُّ مِنكُم محققٌ
        لعلمي ببعد الظَبي عَن كُل مَن هَوى
        وَلَستُ عَلى ما قَد بَدا لي أَلومكم
        فَهَذا جَزا مَن أَجّج النار بِالهَوى
        **التحليل:**
        1. الأسلوب البلاغي:
        القصيدة تتميز باستخدام أسلوب بلاغي عاطفي، حيث يظهر الشاعر مشاعره الداخلية بصدق ووضوح. هناك التكرار في جمل مثل "هويتكم" و"الصدّ"، مما يضفي قوة وتأكيدًا على مشاعر الشاعر. كما أن الشاعر يستخدم التشبيه في قوله "لعلمي ببعد الظبي عن كل من هوى"، حيث يشبه المسافة بينه وبين محبوبته بالمسافة بين الظبي والصياد، مما يعزز الفكرة عن الفراق والبعد.

        2. الإيقاع:
        القصيدة تحمل إيقاعًا موسيقيًا هادئًا، خاصة مع التوازن بين الأبيات واستخدام الوزن الطويل الذي يناسب الموضوع العاطفي الذي يتناوله الشاعر.

        3. المعنى العام:
        القصيدة تعبر عن الألم الناتج عن الفراق والهجر، حيث يصف الشاعر قلبه الذي ذاب بسبب الحب. هو يعترف بأنه هوى المحبوب، ولكنه في نفس الوقت لا يلومه على بعده، لأنه يدرك استحالة الوصول إليه. يختتم بتعبير عن تقديره للمصير الذي جلبه له الهوى.

        4. الدلالات الثقافية:
        القصيدة تتماشى مع التراث الشعري العربي الذي يعبر عن معاناة الحب والفراق، وهي تذكرنا بشعراء الغزل الذين يتناولون الصراع الداخلي بين الحب والألم، ويدل على أن الحب في الثقافة العربية قد يتسبب في معاناة كبيرة.

        الخلاصة:
        القصيدة تعبر عن مشاعر الحزن والألم بسبب الحب البعيد، مع الاعتراف بالواقع المؤلم للفراق، وتعرض صراعًا داخليًا بين الهوى والظروف المستحيلة.


        ### مهمة التحليل:
        حلّل القصيدة التالية وقدم تحليلاً أدبيًا يشمل الأسلوب البلاغي، الإيقاع، المعنى العام، وأي دلالات ثقافية:
        {poem}
        [/INST]
        """  

        analysis_result = model.generate_text(prompt=prompt, guardrails=False)
        return jsonify({"analysis": analysis_result}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/analyze_theme', methods=['POST'])
def analyze_theme():
    data = request.json
    poem = data.get('poem')

    if not poem:
        return jsonify({"error": "No poem provided"}), 400

    try:
        prompt = f"""
        <s>[INST] <<SYS>> 
        أنت ناقد أدبي متخصص في الشعر العربي، ولديك قدرة فائقة على تحديد المواضيع الرئيسية في النصوص.
        <</SYS>> 
        [/INST]
        <s>[INST]
        ### أمثلة على تحديد الموضوع الرئيسي:

        **مثال ١:**
        **القصيدة:**
        هـــــذا زمـــــانٌ مـــولَــعٌ بــالـتـيـهِ
        فــيــه الـغـرائـبُ والـعـجـائبُ فــيـه
        قـانــونُه الـرسـميُّ خــالـفْ أمــةً
        بـلـغَتْ حــدودَ الـمـجدِ فـي الـتنْزِيـه
        حـتـى تــكــونَ مـفـكـراً مـتـحـرراً
        كـــنْ تـابـعـاً لـلـغـربِ مــثـلَ بـنـيـه 
        
        الموضوع الرئيسي: نقد المجتمع وتوجهاته

        التفسير: القصيدة تتناول نقد الشاعر للتغيرات التي طرأت على المجتمع، مبرزًا ما يراه من "غرائب وعجائب" في زمنه، وتعرضه لقانونٍ رسمي يتناقض مع قيم المجد والتنزيه. يبرز الشاعر فكرته من خلال تأكيده على أن الفكر المتحرر أصبح يُربط بالتبعية للغرب، مما يعكس قلقه من هذه التحولات الاجتماعية والثقافية.


        **مثال ٢:**
        **القصيدة:**
        إن القناعة كنز ليس بالفاني فاغنم هديت أخي عيشها الفاني  وعش قنوعاً بلا حرص ولا طمع تعش حميداً رفيع القدر والشاني
        
        الموضوع الرئيسي: القناعة والرضا

        التفسير:
        القصيدة تُعبّر عن فضيلة القناعة وفضلها في حياة الإنسان. يُشَجِّع الشاعر أخاه على أن يعيش قنوعاً دون حرص أو طمع، مُشيرًا إلى أن القناعة تجلب السعادة والرفعة في الدنيا والآخرة. كما يظهر أن الشخص القنوع يتمتع بمقام عالي وسمعة طيبة بين الناس.


        ### مهمة التحديد:
        حدد الموضوع الرئيسي للقصيدة التالية، مع تقديم تفسير موجز لكيفية وصولك إلى هذا الاستنتاج:

        {poem}
        [/INST]
        """

        # Generate response using the improved prompt
        theme_analysis = model.generate_text(prompt=prompt, guardrails=False)
        return jsonify({"theme": theme_analysis}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/generate_poem', methods=['POST'])
def generate_poem():
    data = request.json
    prompt = data.get('prompt')
    meter = data.get('meter')
    theme = data.get('theme')
    rhyme = data.get('rhyme')
    era = data.get('era')
    poet = data.get('poet')

    if not prompt:
        return jsonify({"error": "لم يتم توفير أي نص"}), 400  # Error in Arabic

    try:
        prompt_text = f"""
        <s>[INST] <<SYS>>
        أنت شاعرٌ مُبدعٌ، قادرٌ على نظمِ أشعارٍ مُتماسِكةٍ وجميلةٍ في الوزنِ والقافيةِ.  تُراعي في شعركَ المعنى، والصورةَ الفنية، وجمالَ الأسلوب.
        <</SYS>>
        <s>[INST]
        ### أمثلة على إنشاء قصائد:

        **مثال ١:**
        **النص:** وصف جمال الطبيعة في فصل الربيع
        **القصيدة:**
        أتى الربيعُ يَحملُ الأزهارا *** ونَشَرَ في الكونِ أنوارا
        طَيرٌ يُغنِّي على أغصانِهِ *** فيَرتَوي مِن نَغَمِهِ الكونُ سِحْرا


        **مثال ٢:**
        **النص:** التعبير عن الحنين إلى الوطن
        **القصيدة:**
        وَطني أيا مَوطِني *** حُبُّكَ في قَلبي لَهيبُ
        شَوقي إليكَ يَزيدُ *** كُلَّما طالَ الغَريبُ


        ### مهمة الإنشاء:
        انشئ قصيدة بناءً على النص التالي:
        {prompt}
        """

        constraints = []
        if meter:
            constraints.append(f"على بحر {meter}")
        if theme:
            constraints.append(f"موضوعها {theme}")
        if rhyme:
            constraints.append(f"قافيتها {rhyme}")
        if era:
            constraints.append(f"بأسلوب عصر {era}")
        if poet:
            constraints.append(f"بأسلوب الشاعر {poet}")

        if constraints:
            prompt_text += f"  يجب أن تكون القصيدة {', '.join(constraints)}."


        prompt_text += "[/INST]"

        generated_poem = model.generate_text(prompt=prompt_text, guardrails=False) 

        return jsonify({"poem": generated_poem}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500 # You might want to translate this error message as well if you need Arabic errors.

# Route for generating poems
@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    prompt = data.get('question')  # Expecting a fully formatted 'question' from Flutter

    if not prompt:
        return jsonify({"error": "No prompt provided"}), 400

    # Generate the response from Watsonx API using the provided prompt
    try:
        generated_response = model.generate_text(prompt=prompt, guardrails=False)
        return jsonify({"poem": generated_response}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/generate_chat_response', methods=['POST']) # New route for chat
def generate_chat_response():
    data = request.json
    messages = data.get('messages') # Get the conversation history

    if not messages:
        return jsonify({"error": "No messages provided"}), 400

    try:
        prompt = """<s>[INST] <<SYS>>
        أنتَ مُساعدٌ مُتخصِّصٌ في الشِّعرِ العربيِّ، على استعدادٍ للإجابةِ عن أسئلتِكَ ومُناقشةِ أيِّ موضوعٍ يتعلَّقُ بهِ.  مَعرفتُكَ تشملُ تاريخَ الشِّعرِ، حياةَ الشُّعراءِ، المُصطلحاتِ الأدبيَّةَ، و مختلفَ المدارسِ والتياراتِ الشعريَّةِ.  تذكَّرْ دائماً سياقَ المحادثةِ لتقديمِ إجاباتٍ مُتكاملةٍ ودقيقةٍ.
        <</SYS>>
        """

        for message in messages:
            sender = message.get('sender')
            text = message.get('message')

            if sender == 'user':
                prompt += f"<s> [INST] {text} [/INST]\n"  # Wrap user messages in INST tags
            elif sender == 'ai':
                prompt += f"{text}\n" #  AI messages don't need tags

        response = model.generate_text(prompt=prompt, guardrails=False)
        return jsonify({"response": response}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Route for analyzing meter
@app.route('/analyze_meter', methods=['POST'])
def analyze_meter():
    data = request.json
    poem = data.get('poem')

    if not poem:
        return jsonify({"error": "No poem provided"}), 400

    try:
        result = poetry_classifier(poem)
        meter = result[0]['label']  # Assuming the top prediction is the meter
        score = result[0]['score'] 
        return jsonify({"meter": meter, "score": score}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)